class LoanSummary {
  final int totalBorrowed;
  final int totalPaid;
  final int totalDue;

  LoanSummary({
    required this.totalBorrowed,
    required this.totalPaid,
    required this.totalDue,
  });

  factory LoanSummary.fromMap(Map<String, dynamic> m) => LoanSummary(
        totalBorrowed: (m['total_borrowed'] as num?)?.toInt() ?? 0,
        totalPaid: (m['total_paid'] as num?)?.toInt() ?? 0,
        totalDue: (m['total_due'] as num?)?.toInt() ?? 0,
      );
}

class LoanItem {
  final int id;
  final String applyDate;
  final int amount;
  final int installmentNo;
  final int perInstallAmount;
  final int installmentPaid;
  final int paidAmount;
  final int dueAmount;
  final int dueInstallment;
  final String repaymentFrom;
  final bool deductFromSalary;
  final String status;

  LoanItem({
    required this.id,
    required this.applyDate,
    required this.amount,
    required this.installmentNo,
    required this.perInstallAmount,
    required this.installmentPaid,
    required this.paidAmount,
    required this.dueAmount,
    required this.dueInstallment,
    required this.repaymentFrom,
    required this.deductFromSalary,
    required this.status,
  });

  factory LoanItem.fromMap(Map<String, dynamic> m) => LoanItem(
        id: (m['id'] as num?)?.toInt() ?? 0,
        applyDate: m['apply_date'] as String? ?? '',
        amount: (m['amount'] as num?)?.toInt() ?? 0,
        installmentNo: (m['installment_no'] as num?)?.toInt() ?? 0,
        perInstallAmount: (m['per_install_amount'] as num?)?.toInt() ?? 0,
        installmentPaid: (m['installment_paid'] as num?)?.toInt() ?? 0,
        paidAmount: (m['paid_amount'] as num?)?.toInt() ?? 0,
        dueAmount: (m['due_amount'] as num?)?.toInt() ?? 0,
        dueInstallment: (m['due_installment'] as num?)?.toInt() ?? 0,
        repaymentFrom: m['repayment_from'] as String? ?? '',
        deductFromSalary: m['deduct_from_salary'] as bool? ?? false,
        status: m['status'] as String? ?? '',
      );
}

class LoanResponse {
  final LoanSummary summary;
  final List<LoanItem> list;

  LoanResponse({required this.summary, required this.list});
}

LoanResponse loanResponseFromMap(dynamic body) {
  final data = body['data'] as Map<String, dynamic>;
  return LoanResponse(
    summary: LoanSummary.fromMap(data['summary'] as Map<String, dynamic>),
    list: (data['list'] as List<dynamic>)
        .map((e) => LoanItem.fromMap(e as Map<String, dynamic>))
        .toList(),
  );
}
