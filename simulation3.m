clear all; clc;

% Set a random seed for reproducibility
rng(42);  % Set a seed to get the same random points every time

% Load environment
load("gridmap_20x20_scene1.mat");
map_size = size(grid_map);

% Assume that 1 represents free space and 2 represents obstacles.
free_space_value = 1;

G = 1;

% Simulation mode
mode = "static";

% Number of runs and algorithms
num_runs = 5;  % Set to 5 different start and goal points
algorithms = {'dijkstra', 'a_star', 'gbfs'};  % The three algorithms
num_algorithms = length(algorithms);

% Pre-allocate arrays to store path lengths, times, and costs for each algorithm
path_lengths = zeros(num_runs, num_algorithms);
times = zeros(num_runs, num_algorithms);
costs = zeros(num_runs, num_algorithms);

% Define a time limit for each algorithm per run (in seconds)
time_limit = 5;  % Set a time limit for each algorithm

% Find all free spaces in the grid
[free_rows, free_cols] = find(grid_map == free_space_value);  % Use 1 for free space
free_spaces = [free_rows, free_cols];  % Combine rows and columns into a list of free spaces
num_free_spaces = size(free_spaces, 1);  % Define num_free_spaces based on free spaces

if num_free_spaces == 0
    error('No free spaces available in the grid.');
end

% Generate random start and goal points for each run
start_points = zeros(num_runs, 2);
goal_points = zeros(num_runs, 2);
for i = 1:num_runs
    % Generate random start and goal points from the free spaces
    rand_idx_start = randi(num_free_spaces);  % Pick random start point
    rand_idx_goal = randi(num_free_spaces);   % Pick random goal point
    start_points(i, :) = free_spaces(rand_idx_start, :);  
    goal_points(i, :) = free_spaces(rand_idx_goal, :);  
end

% Run each algorithm with the same start and goal points
paths = cell(num_runs, num_algorithms);  % Store paths for visualization
for j = 1:num_algorithms
    planner_name = algorithms{j};
    planner = str2func(planner_name);  % Convert to function handle
    
    for i = 1:num_runs
        start = start_points(i, :);
        goal = goal_points(i, :);
        tic;  % Start timer
        
        % Run the algorithm and stop if it takes too long
        try
            [path, flag, cost, expand] = planner(grid_map, start, goal);
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
        end
        costs(i, j) = cost;  % Store cost
    end
end

% Display the statistics
mean_path_lengths = mean(path_lengths);
median_path_lengths = median(path_lengths);

disp('Mean path lengths:');
disp(mean_path_lengths);

disp('Median path lengths:');
disp(median_path_lengths);

disp('Mean times (seconds):');
disp(mean(times));

disp('Mean costs:');
disp(mean(costs));

% Plot the grid map with start and goal for each run
figure;
imagesc(grid_map);  % Display the grid map
hold on;
colormap(gray);  % Set color to grayscale
axis equal;
title('Grid Map with Paths for Different Start and Goal Points');
xlabel('X');
ylabel('Y');

% Plot start and goal points with specific colors and shapes
for i = 1:num_runs
    plot(goal_points(i, 2), goal_points(i, 1), 'r*', 'MarkerSize', 10);  % Plot goals (red star)
    plot(start_points(i, 2), start_points(i, 1), 'bo', 'MarkerSize', 8);  % Plot start points (blue circle)
end

% Assign colors: A* = blue, Dijkstra = green, GBFS = red
algorithm_colors = {'g', 'b', 'r'}; 

% Plot paths for each algorithm with assigned colors
for j = 1:num_algorithms
    for i = 1:num_runs
        if ~isempty(paths{i, j})
            path = paths{i, j};
            
            % Interpolate with cubic spline to smooth the path
            t = 1:length(path);
            t_interp = linspace(1, length(path), 100);  % 100 interpolated points
            path_interp = interp1(t, path, t_interp, 'spline');  % Spline interpolation
            
            plot(path_interp(:, 2), path_interp(:, 1), algorithm_colors{j}, 'LineWidth', 2);  % Plot the smoothed path with color
        end
    end
end

% Update the legend to reflect the correct colors and symbols for each algorithm
legend({'Goal (red star)', 'Start (blue circle)', 'Dijkstra (green)', 'A* (blue)', 'GBFS (red)'}, 'Location', 'best');

hold off;

% Plot the path lengths for all algorithms in one bar chart
figure;
bar(path_lengths);
xlabel('Run Number');
ylabel('Path Length');
title('Path Length per Run for Different Algorithms');
legend(algorithms, 'Location', 'best');
xticks(1:num_runs);

% Plot histogram for path lengths with clearer heights and separate colors
figure;
for j = 1:num_algorithms
    subplot(1, num_algorithms, j);
    histogram(path_lengths(:, j), 'FaceColor', algorithm_colors{j}, 'EdgeColor', 'k');  % Set color for each algorithm
    title(['Path Length Histogram - ' algorithms{j}]);
    xlabel('Path Length');
    ylabel('Frequency');
end
set(gcf, 'Position', [100, 100, 800, 400]);  % Resize the figure for better clarity

% Plot the times for all algorithms in a separate figure with smaller histogram bars
figure;
bar(times, 'BarWidth', 0.4);  % Set a smaller bar width for clarity
xlabel('Run Number');
ylabel('Time (seconds)');
title('Time Taken per Run for Different Algorithms');
legend(algorithms, 'Location', 'best');
xticks(1:num_runs);
set(gcf, 'Position', [100, 100, 800, 400]);  % Resize the figure for better clarity
