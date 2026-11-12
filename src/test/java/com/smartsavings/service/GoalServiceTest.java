package com.smartsavings.service;

import com.smartsavings.dto.DepositRequest;
import com.smartsavings.dto.GoalRequest;
import com.smartsavings.dto.GoalResponse;
import com.smartsavings.repository.GoalRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class GoalServiceTest {

    @Autowired
    private GoalService goalService;

    @Autowired
    private GoalRepository goalRepository;

    @Autowired
    private MockMvc mockMvc;

    @BeforeEach
    void cleanGoals() {
        goalRepository.deleteAll();
    }

    @Test
    void depositAndWithdrawalUpdateAmountAndStatus() {
        GoalResponse created = goalService.create(new GoalRequest(
                "Viagem",
                100.0,
                LocalDate.of(2027, 1, 1)
        ));

        GoalResponse completed = goalService.addDeposit(created.id(), new DepositRequest(
                100.0,
                LocalDate.now()
        ));

        assertThat(completed.currentAmount()).isEqualTo(100.0);
        assertThat(completed.status()).isEqualTo("CONCLUIDA");
        assertThat(completed.deposits()).hasSize(1);

        GoalResponse inProgress = goalService.addDeposit(created.id(), new DepositRequest(
                -20.0,
                LocalDate.now()
        ));

        assertThat(inProgress.currentAmount()).isEqualTo(80.0);
        assertThat(inProgress.status()).isEqualTo("EM_ANDAMENTO");
        assertThat(inProgress.deposits()).hasSize(2);
        assertThat(goalRepository.findById(created.id())).isPresent();
    }

    @Test
    void createEndpointValidatesRequestAndReturnsCreatedGoal() throws Exception {
        mockMvc.perform(post("/api/goals")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "title": "Reserva",
                                  "targetAmount": 250.0,
                                  "dueDate": "2027-06-30"
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.title").value("Reserva"))
                .andExpect(jsonPath("$.currentAmount").value(0.0))
                .andExpect(jsonPath("$.status").value("EM_ANDAMENTO"));

        mockMvc.perform(post("/api/goals")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "title": "Inválida",
                                  "targetAmount": 0.0,
                                  "dueDate": "2027-06-30"
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.details.targetAmount").exists());
    }
}
