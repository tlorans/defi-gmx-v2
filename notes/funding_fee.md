# funding fee

larger side pays smaller side

`MarketUtils.getNextFundingAmountPerSize`

`MarketUtils.getNextFundingFactorPerSecond`

`funding usd = larger side open interest * funding per sec * dt from last update`

```
f = |o - s| ^ e / (o  + s)
Fi = funding increase factor per sec

if Fi = 0
   funding factor per sec = min(f * F_market, max funding factor per sec)


if is_skew_same_dir_as_funding
   if f > stable funding threshold
      increase funding rate
   else if f < decrease threshold
      decrease funding rate
else
   increase funding rate

if Fi > 0
   if funding rate increase
      funding factor per sec = prev funding factor per sec + f * Fi * dt

   if funding rate decrease
      if prev funding factor per sec <= Fd * dt
         funding factor per sec = +/- 1 (preserve prev sign)
      else
         funding factor per sec = +/- 1 (preserve prev sign) * (funding factor per sec - Fd * dt)

TODO: bound funding factor per sec

funding fee in USD per size = f * dt * size of larger side / size of smaller side
```
