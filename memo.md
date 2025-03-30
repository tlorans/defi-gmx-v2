### Introduction

Application ideas

```
1. Any integration that can help grow trading volume.

2. A delta-neutral funding fee vault, allowing a user to earn GMX funding fees automatically with a delta-neutral position (e.g. holding ETH and shorting ETH when funding is paying shorts).

3. Or, alternatively, an unhedged version of the above instrument. Where a user just takes a position on the side that pays funding fees, counter-trading the existing traders on GMX.

4. A price impact vault, which capitalises on this opportunity on GMX by automatically capturing the value from positive price impact when it becomes available.
```

##### TODO

- application
  - short ETH + ETH collateral payoff
    - UI demo
  - strategy
    - open short when funding fee > 0
    - close short when funding fee < 0
    - close short when short profit
    - admin is a decent trader
  - contract architecture
    - token + execution fee flow
      - deposit, withdraw, cancel
    - token and ETH is split for simple accounting
  - technical detail
    - vault inflation attack?
  - exercises
  - solution
