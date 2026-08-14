class ActivityLogEntity {
  final String id;
  final String actionType;
  final String details;
  final String createdAt;

  const ActivityLogEntity({
    required this.id,
    required this.actionType,
    required this.details,
    required this.createdAt,
  });
}

class ReferralEntity {
  final String referralCode;
  final String referralLink;
  final int totalReferrals;
  final double totalEarnings;
  final int rewardPoints;

  const ReferralEntity({
    required this.referralCode,
    required this.referralLink,
    required this.totalReferrals,
    required this.totalEarnings,
    required this.rewardPoints,
  });
}
