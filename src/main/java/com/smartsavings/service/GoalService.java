package com.smartsavings.service;

import com.smartsavings.dto.DepositRequest;
import com.smartsavings.dto.DepositResponse;
import com.smartsavings.dto.GoalRequest;
import com.smartsavings.dto.GoalResponse;
import com.smartsavings.entity.Deposit;
import com.smartsavings.entity.Goal;
import com.smartsavings.exception.ResourceNotFoundException;
import com.smartsavings.repository.GoalRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class GoalService {

    private final GoalRepository goalRepository;

    public GoalService(GoalRepository goalRepository) {
        this.goalRepository = goalRepository;
    }

    @Transactional(readOnly = true)
    public List<GoalResponse> findAll() {
        return goalRepository.findAll().stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public GoalResponse create(GoalRequest request) {
        Goal goal = new Goal(request.title(), request.targetAmount(), request.dueDate());
        return toResponse(goalRepository.save(goal));
    }

    @Transactional
    public GoalResponse update(Long id, GoalRequest request) {
        Goal goal = findGoal(id);
        goal.updateDetails(request.title(), request.targetAmount(), request.dueDate());
        return toResponse(goal);
    }

    @Transactional
    public void delete(Long id) {
        goalRepository.delete(findGoal(id));
    }

    @Transactional
    public GoalResponse addDeposit(Long id, DepositRequest request) {
        Goal goal = findGoal(id);
        goal.addDeposit(new Deposit(request.amount(), request.date()));
        return toResponse(goal);
    }

    private Goal findGoal(Long id) {
        return goalRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Meta não encontrada: " + id));
    }

    private GoalResponse toResponse(Goal goal) {
        List<DepositResponse> deposits = goal.getDeposits().stream()
                .map(deposit -> new DepositResponse(
                        deposit.getId(),
                        deposit.getAmount(),
                        deposit.getDate()
                ))
                .toList();

        return new GoalResponse(
                goal.getId(),
                goal.getTitle(),
                goal.getTargetAmount(),
                goal.getCurrentAmount(),
                goal.getDueDate(),
                goal.getStatus().name(),
                deposits
        );
    }
}
