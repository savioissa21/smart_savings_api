package com.smartsavings.dto;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

public record DepositRequest(
        @NotNull(message = "O valor da movimentação é obrigatório.")
        Double amount,
        @NotNull(message = "A data da movimentação é obrigatória.")
        LocalDate date
) {
    @AssertTrue(message = "O valor da movimentação não pode ser zero.")
    public boolean isAmountNonZero() {
        return amount != null && amount != 0.0;
    }
}
