import '../../domain/entities/activity_log_entity.dart';

class ActivityLogModel extends ActivityLogEntity {
  const ActivityLogModel({
    required String id,
    required String actionType,
    required String details,
    required String createdAt,
  }) : super(
          id: id,
          actionType: actionType,
          details: details,
          createdAt: createdAt,
        );

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] as String? ?? 'act_${DateTime.now().millisecondsSinceEpoch}',
      actionType: json['actionType'] as String? ?? 'USER_ACTION',
      details: json['details'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actionType': actionType,
      'details': details,
      'createdAt': createdAt,
    };
  }
}

class ReferralModel extends ReferralEntity {
  const ReferralModel({
    required String referralCode,
    required String referralLink,
    required int totalReferrals,
    required double totalEarnings,
    required int rewardPoints,
  }) : super(
          referralCode: referralCode,
          referralLink: referralLink,
          totalReferrals: totalReferrals,
          totalEarnings: totalEarnings,
          rewardPoints: rewardPoints,
        );

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      referralCode: json['referralCode'] as String? ?? 'FLASHCART99',
      referralLink: json['referralLink'] as String? ?? 'https://flashcart.ai/ref/FLASHCART99',
      totalReferrals: (json['totalReferrals'] as num?)?.toInt() ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      rewardPoints: (json['rewardPoints'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referralCode': referralCode,
      'referralLink': referralLink,
      'totalReferrals': totalReferrals,
      'totalEarnings': totalEarnings,
      'rewardPoints': rewardPoints,
    };
  }
}

