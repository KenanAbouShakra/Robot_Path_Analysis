addpath(genpath("../utils/"), genpath("../global_planner/"));

clear all; clc;

% Set a random seed for reproducibility
rng(42);  % Set a seed to get the same random points every time

% Load environment
load("warehouse.mat");
map_size = size(warehouse);  % Use 'warehouse' as the map variable

% Assume that 1 represents free space and 2 represents obstacles.
free_space_value = 1;

G = 1;

% Simulation mode
mode = "static";

% Number of runs and algorithms
num_runs = 5;  % Set to 30 runs with random start points and a fixed goal point
algorithms = {'dijkstra', 'a_star', 'gbfs', 'jps'};  % Add JPS to the list of algorithms
num_algorithms = length(algorithms);

% Pre-allocate arrays to store path lengths, times, and costs for each algorithm
path_lengths = zeros(num_runs, num_algorithms);
times = zeros(num_runs, num_algorithms);
costs = zeros(num_runs, num_algorithms);

% Define a time limit for each algorithm per run (in seconds)
time_limit = 5;  % Set a time limit for each algorithm

% Find all free spaces in the warehouse map
[free_rows, free_cols] = find(warehouse == free_space_value); 
free_spaces = [free_rows, free_cols];  % Combine rows and columns into a list of free spaces
num_free_spaces = size(free_spaces, 1);  % Define num_free_spaces based on free spaces

if num_free_spaces == 0
    error('No free spaces available in the grid.');
end

% Set a fixed goal point at (19, 29)
fixed_goal = [19, 29];  % Manually set the fixed goal point

% Generate random start points for each run (with fixed goal point)
start_points = zeros(num_runs, 2);
for i = 1:num_runs
    % Generate random start points from the free spaces
    rand_idx_start = randi(num_free_spaces);  % Pick random start point
    start_points(i, :) = free_spaces(rand_idx_start, :);  
end

% Run each algorithm with the same start points and fixed goal point
paths = cell(num_runs, num_algorithms);  % Store paths for visualization
for i = 1:num_runs
    figure;  % Create a new figure for each run
    imagesc(warehouse);  % Display the warehouse map
    hold on;
    colormap("sky");  % Set color to grayscale
    axis equal;
    title(['Run ', num2str(i), ' - All Algorithms']);
    xlabel('X');
    ylabel('Y');

    % Plot start and goal points for this run
    plot(fixed_goal(2), fixed_goal(1), 'r*', 'MarkerSize', 10);  % Plot goal (red star)
    plot(start_points(i, 2), start_points(i, 1), 'bo', 'MarkerSize', 8);  % Plot random start point (blue circle)
    
    % Colors for each algorithm: Dijkstra = blue, A* = orange, GBFS = green, JPS = cyan
    colors = {[0.2 0.6 0.9], [0.9 0.6 0.2], [0.6 0.9 0.2], [0.2 0.8 0.8]};  % Add cyan for JPS

    algorithm_colors = colors;
    
    for j = 1:num_algorithms
        planner_name = algorithms{j};
        planner = str2func(planner_name);  % Convert to function handle
        
        start = start_points(i, :);
        goal = fixed_goal;
        tic;  % Start timer

        % Run the algorithm and stop if it takes too long
        try
            [path, flag, cost, expand] = planner(warehouse, start, goal);  % Use 'warehouse' here
        catch
            warning(['Error running ', planner_name, ' on run ', num2str(i)]);
            continue;  % Skip this iteration if the algorithm fails
        end

        elapsed_time = toc;  % Measure elapsed time
        
        if elapsed_time > time_limit
            warning(['Algorithm ', planner_name, ' exceeded time limit on run ', num2str(i)]);
            continue;  % Skip if time limit is exceeded
        end
        
        times(i, j) = elapsed_time;  % Store the elapsed time
        
        % Calculate path length
        if isempty(path)
            path_lengths(i, j) = 0;
        else
            path_lengths(i, j) = length(path);
            paths{i, j} = path;  % Store the path for visualization

            % Interpolate with cubic spline to smooth the path
            t = 1:length(path);
            t_interp = linspace(1, length(path), 100);  % 100 interpolated points
            path_interp = interp1(t, path, t_interp, 'spline');  % Spline interpolation

            % Plot the smoothed path with assigned color for each algorithm
            plot(path_interp(:, 2), path_interp(:, 1), 'Color', algorithm_colors{j}, 'LineWidth', 2);  
        end
        costs(i, j) = cost;  % Store cost
    end
    
    % Update the legend for the current plot
    legend({'Goal (red star)', 'Start (blue circle)', 'Dijkstra', 'A*', 'GBFS', 'JPS'}, 'Location', 'best');
    
    hold off;
    pause(1);  % Pause to allow viewing before proceeding to the next run
end
