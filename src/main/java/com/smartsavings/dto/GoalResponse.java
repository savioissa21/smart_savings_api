package com.smartsavings.dto;

import java.time.LocalDate;
import java.util.List;

public record GoalResponse(
        Long id,
        String title,
        Double targetAmount,
        Double currentAmount,
        LocalDate dueDate,
        String status,
        List<DepositResponse> deposits
) {
}
