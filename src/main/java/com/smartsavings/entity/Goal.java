package com.smartsavings.entity;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "goals")
public class Goal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private Double targetAmount;

    @Column(nullable = false)
    private Double currentAmount = 0.0;

    @Column(nullable = false)
    private LocalDate dueDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private GoalStatus status = GoalStatus.EM_ANDAMENTO;

    @OneToMany(mappedBy = "goal", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Deposit> deposits = new ArrayList<>();

    protected Goal() {
    }

    public Goal(String title, Double targetAmount, LocalDate dueDate) {
        this.title = title;
        this.targetAmount = targetAmount;
        this.dueDate = dueDate;
        recalculateStatus();
    }

    public void updateDetails(String title, Double targetAmount, LocalDate dueDate) {
        this.title = title;
        this.targetAmount = targetAmount;
        this.dueDate = dueDate;
        recalculateStatus();
    }

    public void addDeposit(Deposit deposit) {
        deposits.add(deposit);
        deposit.setGoal(this);
        currentAmount += deposit.getAmount();
        recalculateStatus();
    }

    private void recalculateStatus() {
        status = currentAmount >= targetAmount
                ? GoalStatus.CONCLUIDA
                : GoalStatus.EM_ANDAMENTO;
    }

    public Long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public Double getTargetAmount() {
        return targetAmount;
    }

    public Double getCurrentAmount() {
        return currentAmount;
    }

    public LocalDate getDueDate() {
        return dueDate;
    }

    public GoalStatus getStatus() {
        return status;
    }

    public List<Deposit> getDeposits() {
        return deposits;
    }
}
