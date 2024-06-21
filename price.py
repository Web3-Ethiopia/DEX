import math

def price_to_tick(p):
    return math.floor(math.log(p, 1.0001))

print(price_to_tick(5500))

