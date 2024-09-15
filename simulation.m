addpath(genpath("../utils/"), genpath("../global_planner/"));

clear all; clc;

% random seed
rng(123)

% load env
load("warehouse.mat");
map_size = size(warehouse);
G = 1;

% simulation mode
mode = "static";
% Number of runs and algorithms
num_runs = 30;
algorithms = {'dijkstra', 'a_star', 'gbfs'};  % The three algorithms
num_algorithms = length(algorithms);  % Total number of algorithms

% Pre-allocate arrays to store costs for each algorithm
costs = zeros(num_runs, num_algorithms);  % Each column represents an algorithm
times = zeros(num_runs, num_algorithms);  % Each column represents an algorithm
goal = [18, 29];  % Goal position
start_points = zeros(num_runs, 2);  % Store start points

min_dist = 1;  % Define the maximum allowed distance from the goal
max_dist = 15;
for i = 1:num_runs
    valid_point = false;
    while ~valid_point
        % Generate random start point
        candidate_point = [randi(map_size(1)), randi(map_size(2))];
        
        % Calculate Euclidean distance to the goal
        dist_to_goal = sqrt((candidate_point(1) - goal(1))^2 + (candidate_point(2) - goal(2))^2);
        % Check if the distance is less than 'x'
        if dist_to_goal < max_dist && dist_to_goal > min_dist && warehouse(candidate_point(1), candidate_point(2)) == 1 && ~ismember(candidate_point, start_points, 'rows')
            valid_point = true;
            start_points(i, :) = candidate_point;  % Store the valid point
        end
    end
end
figure;
plot_grid(warehouse)
hold on
for i = 1:size(start_points)
    plot_square(start_points(i, :), map_size, 1, '#f00')
end

plot_square(goal, map_size, 1, '#15c')
hold off;

% Run each algorithm with the same start points
for j = 1:num_algorithms
    planner_name = algorithms{j};  % Get the algorithm name
    planner = str2func(planner_name);  % Convert to function handle
    
    for i = 1:num_runs
        start = start_points(i, :);  % Get the start point for this run
        tic;
        [path, flag, cost, expand] = planner(warehouse, start, goal);  % Call the planner
        times(i, j) = toc;
        costs(i, j) = cost;  % Store the cost for this algorithm and run
        
    end
end

% Calculate average and standard deviation for each algorithm
avg_cost = mean(costs);
std_cost = std(costs);

avg_time = mean(times);
std_time = std(times);
disp(std_time)
disp(avg_time)


% Define colors for the bars
colors = [0.2 0.6 0.9; 0.9 0.6 0.2; 0.6 0.9 0.2];

% Create the bar plot with error bars
figure;
b = bar(avg_cost, 'FaceColor', 'flat');
b.CData = colors; % Set colors for the bars

hold on;
% Add error bars
errorbar(1:length(avg_cost), avg_cost, std_cost, 'k.', 'LineWidth', 1.5);

% Display numerical values on the bars
for i = 1:length(avg_cost)
    text(i, avg_cost(i) + std_cost(i) * 0.1, sprintf('%.2f', avg_cost(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10);
end

hold off;

% Set the plot labels and title
set(gca, 'XTick', 1:length(algorithms), 'XTickLabel', algorithms);
xlabel('Algorithm');
ylabel('Cost');
title('Average Cost and Standard Deviation for Motion Planning Algorithms');
grid on;

% Create the bar plot with error bars
figure;
b = bar(avg_time, 'FaceColor', 'flat');
b.CData = colors; % Set colors for the bars

hold on;
% Add error bars
errorbar(1:length(avg_time), avg_time, std_time, 'k.', 'LineWidth', 1.5);

% Display numerical values on the bars
for i = 1:length(avg_cost)
    text(i, avg_time(i) + std_time(i) * 0.1, sprintf('%.2f', avg_time(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10);
end

hold off;

% Set the plot labels and title
set(gca, 'XTick', 1:length(algorithms), 'XTickLabel', algorithms);
xlabel('Algorithm');
ylabel('Cost');
title('Average Time and Standard Deviation for Motion Planning Algorithms');
grid on;