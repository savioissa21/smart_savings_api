package com.smartsavings.dto;

import java.time.LocalDate;

public record DepositResponse(Long id, Double amount, LocalDate date) {
}
