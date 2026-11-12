package com.smartsavings.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.time.LocalDate;

public record GoalRequest(
        @NotBlank(message = "O título é obrigatório.")
        String title,
        @NotNull(message = "O valor alvo é obrigatório.")
        @Positive(message = "O valor alvo deve ser maior que zero.")
        Double targetAmount,
        @NotNull(message = "A data limite é obrigatória.")
        LocalDate dueDate
) {
}
