addpath(genpath("../utils/"), genpath("../global_planner/"));

clear all; clc;

% load environment
load("gridmap_20x20_scene1.mat");
map_size = size(grid_map);
disp(map_size(1))
G = 1;

% simulation mode
mode = "static";
% Number of runs and algorithms
num_runs = 5;
algorithms = {'dijkstra', 'a_star', 'gbfs'};  % The three algorithms
num_algorithms = length(algorithms);  % Total number of algorithms

% Pre-allocate arrays to store costs for each algorithm
costs = zeros(num_runs, num_algorithms);  % Each column represents an algorithm

goal = [18, 29];  % Goal position
map_size = size(grid_map);  % Size of the grid map

% Generate random start points for each run
start_points = zeros(num_runs, 2);  % Store start points
for i = 1:num_runs
    start_points(i, :) = [randi(map_size(1)), randi(map_size(2))];  % Random start
end

% Run each algorithm with the same start points
for j = 1:num_algorithms
    planner_name = algorithms{j};  % Get the algorithm name
    planner = str2func(planner_name);  % Convert to function handle
    
    for i = 1:num_runs
        start = start_points(i, :);  % Get the start point for this run
        [path, flag, cost, expand] = planner(grid_map, start, goal);  % Call the planner
        costs(i, j) = cost;  % Store the cost for this algorithm and run
    end
end

% Plot the costs for all algorithms in one bar chart
figure;
bar(costs);  % Create a bar chart for costs

% Customize the plot
xlabel('Run Number');
ylabel('Cost');
title('Cost per Run for Different Algorithms');
legend(algorithms, 'Location', 'best');  % Add a legend for algorithms
xticks(1:num_runs);  % Set x-ticks to match run numbers

% if mode == "static"
%     clf; hold on
% 
%     % plot grid map
%     plot_grid(grid_map);
% 
%     % plot expand zone
%     plot_expand(expand, map_size, G, planner_name);
% 
%     % plot path
%     plot_path(path, G);
% 
%     % plot start and goal
%     plot_square(start, map_size, G, "#f00");
%     plot_square(goal, map_size, G, "#15c");
%     % title
%     title([planner_name, "cost:" + num2str(cost)], 'Interpreter','none');
% 
%     hold off
% end