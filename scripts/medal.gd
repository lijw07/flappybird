class_name Medal

enum Tier { NONE, BRONZE, SILVER, GOLD, PLATINUM }

const THRESHOLDS := {
	Tier.PLATINUM: 40,
	Tier.GOLD: 30,
	Tier.SILVER: 20,
	Tier.BRONZE: 10,
}


static func tier_for_score(score: int) -> Tier:
	for tier in THRESHOLDS:
		if score >= THRESHOLDS[tier]:
			return tier
	return Tier.NONE
