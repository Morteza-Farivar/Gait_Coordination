%% Step 6: Computing Phase angles for Each Trial

% Validate the input data
if ~exist('normalized_cycles_all', 'var') || isempty(normalized_cycles_all)
    error('Normalized gait cycle data is missing. Ensure Step 5 runs successfully before Step 7.');
end

% Define the segments and axes for processing
segments = {'L_thigh', 'L_shank', 'L_foot', ...
            'R_thigh', 'R_shank', 'R_foot', ...
            'pelvis', 'trunk'};
axes = {'X', 'Y', 'Z'};

% Initialize storage for phase angles for all files and trials
num_files = size(normalized_cycles_all, 1); % Number of files
num_trials = size(normalized_cycles_all, 2); % Number of trials
phase_angles = struct();

% Preallocate cell arrays for phase angles
for seg = 1:numel(segments)
    for ax = 1:numel(axes)
        phase_angles.(segments{seg}).(axes{ax}) = cell(num_files, num_trials);
    end
end

disp('Applying Hilbert Transform for each trial and segment...');

% Loop through files and trials
for file_idx = 1:num_files
    for trial_idx = 1:num_trials
        % Check if normalized cycle data exists for this trial
        if isempty(normalized_cycles_all{file_idx, trial_idx})
            fprintf('Skipping file %d, trial %d: No normalized data.\n', file_idx, trial_idx);
            continue;
        end

        % Loop through gait cycles for this trial
        num_cycles = numel(normalized_cycles_all{file_idx, trial_idx});
        for cycle_idx = 1:num_cycles
            % Extract the current cycle data
            current_cycle = normalized_cycles_all{file_idx, trial_idx}{cycle_idx};

            % Process each segment and axis
            for seg = 1:numel(segments)
                for ax = 1:numel(axes)
                    % Construct the column name for the current segment and axis
                    col_name = [segments{seg}, '_', axes{ax}];

                    % Ensure the column exists in the current cycle
                    if isfield(current_cycle, col_name)
                        % Apply Hilbert Transform to compute phase angles
                        phase_angles.(segments{seg}).(axes{ax}){file_idx, trial_idx}{cycle_idx} = ...
                            Hilbert_PA(current_cycle.(col_name));
                    else
                        fprintf('Skipping segment %s, axis %s in file %d, trial %d, cycle %d: Column not found.\n', ...
                                segments{seg}, axes{ax}, file_idx, trial_idx, cycle_idx);
                    end
                end
            end
        end
    end
end

disp('Hilbert Transform applied to all files, trials, and cycles.');

% Save phase angle data to Workspace
assignin('base', 'phase_angles', phase_angles);

disp('Step 6 completed: Phase angles saved successfully.');