# The Story
We have a warehouse robot which is tasked with fetching items from any shelf in the warehouse and bringing them to a conveyor belt for packaging. This means that the start and endpoint of every fetch is the same. To simplify the model we can say that we only go oneway: from the shelf to the drop off point.

We are now concerned with selecting a fast motion planning algorithm which is able to find a decently short path through the maze we call our warehouse. Since time is money, we need the robot to be as fast as possible.

# Algorithms
We are comparing three algorithms to see which works best in our scenario.
## A*
A* is a pathfinding algorithm which uses a heuristic to estimate the distance to the goal at any time. Given the heuristic does not overestimate, A* finds the optimal path and is quite fast in doing so, since it does not have to check all possible paths.

//TODO Make this useful:\
We expect this algorithm to do best in our scenario since 

## Dijkstra
Dijkstra's algorithm explores all possible paths, prioritizing the nodes with the shortest cumulative distance from the start. It's guaranteed to find the shortest path but can be slower than A* since it doesn’t use heuristics.

//TODO Maybe we should introduce timing\
We expect Dijkstra to do well

## Greedy Best First Search
GBFS prioritizes exploring the node that appears to be closest to the goal, using only a heuristic function for guidance. It’s faster than A* but not guaranteed to find the shortest path, as it doesn't account for the cost already traveled, only the estimated distance to the goal.

We expect GBFS to do worst, since it does not neccessarily find the shortest path.

# The simulation
We have a warehouse map with shelfs. We simulate 30 controlled random pickup locations with a distance of x to the goal and another 30 controlled random pickup location with a distance of 2x to the goal.

# Plotting
