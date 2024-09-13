# Questions
- Do we need 3D? Imo totally unnessecary

# What are we doing
Selecting the optimal motion planning algorithm for a warehouse robot. It can pick up wares anywhere in the warehouse and needs to deliver them to a drop-off station. We are using three different algorithms to plan the trajectory: **dijkstra**, **a*** and **gbfs**. We are comparing the cost of the calculation as well as the resulting path length of all algorithms on all possible pick-up locations.

# Hypotheses
We expect a* to do best due to its heuristic nature. Although the path might not always be optimal, it will be very close in most cases. We will save a lot of computation time with the heuristic approach here.

Next best will probably be dijkstra. It will find the optimal path, but that takes time. Its local greedy choices although will be better than gbfs which is expected to perform the worst in terms of time.

# Plan on plotting
- calculate the cost for all algorithms for all possible pickup-location and compare them
- calculate path length in the same manner for comparison