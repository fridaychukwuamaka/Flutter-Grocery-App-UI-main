class Sales {
  const Sales({
    this.product,
    this.status,
    this.buyerId,
    this.date,
    this.total,
  });

  final List product;
  final String status;
  final String buyerId;
  final DateTime date;
  final double total;
}
