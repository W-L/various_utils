#!/usr/bin/env python3

import sys

class Player:
    def __init__(self, name):
        self.name = name
        self.score = 0
        self.call = 0
        self.res = 0
        
    def print(self):
        print(str(self.name) + '.' * 15 + str(self.score))
        
        

def next_round(players, r):
    print('\n############\tRunde ' + str(r) + '\t\t############\n')
    print(str(players[-1].name) + ' gibt\t' + str(players[0].name) + ' beginnt\n')
    
    # ask for calls
    for p in players:
        c = input('Stiche ' + str(p.name) + ': ')
        if c == 'end':
            for p in players:
                p.print()
            sys.exit()
        else:
            p.call = int(c)
        
                    
    # ask for results
    print('\n')
    for p in players:
        p.res = int(input('Resultat ' + str(p.name) + ': '))
        if p.call == p.res:
            p.score += p.call * 10 + 20
        else:
            p.score += abs(p.res - p.call) * -10
    
    print('\n')
    return(players)
        
# initiate    
r = 0
players = []
for n in sys.argv[1:]:
    players.append(Player(name=n))
    
    
while True:
    players = next_round(players=players, r=r)
    
    for p in players:
        p.print()

    # reorder players
    p1 = players.pop(0)
    players.append(p1)
    
    r+=1
    
    