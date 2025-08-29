%% Step 8: Calculate Toe-Off, Stride Time, Step Time, and Swing Time for Right and Left Legs
% Validate input
if ~exist('df_drop_nan', 'var') || ~exist('Lheel_strikes_all', 'var') || ~exist('Rheel_strikes_all', 'var')
    error('Required variables (df_drop_nan, Lheel_strikes_all, Rheel_strikes_all) are missing. Ensure previous steps are completed.');
end

% Initialize storage for all metrics
num_files = size(df_drop_nan, 1);
num_trials = size(df_drop_nan, 2);
toe_off_left = cell(num_files, num_trials);
toe_off_right = cell(num_files, num_trials);
stride_time_left = cell(num_files, num_trials);
stride_time_right = cell(num_files, num_trials);
step_time_left = cell(num_files, num_trials);
step_time_right = cell(num_files, num_trials);
swing_time_left = cell(num_files, num_trials);
swing_time_right = cell(num_files, num_trials);

disp('Step 10: Calculating Toe-Off, Stride Time, Step Time, and Swing Time for Right and Left Legs...');

for file_idx = 1:num_files
    for trial_idx = 1:num_trials
        % Check if data exists for the current trial
        if isempty(df_drop_nan{file_idx, trial_idx})
            fprintf('Skipping file %d, Trial %d: Missing raw data.\n', file_idx, trial_idx);
            continue;
        end

        % Extract raw data for columns 6 (Left Toe-Off) and 12 (Right Toe-Off)
        left_column = df_drop_nan{file_idx, trial_idx}(:, 6); % Left Toe-Off
        right_column = df_drop_nan{file_idx, trial_idx}(:, 12); % Right Toe-Off

        % Find Toe-Off indices (minimum values)
        [~, toe_off_left_idx] = findpeaks(-left_column); % Negative for minima
        [~, toe_off_right_idx] = findpeaks(-right_column); % Negative for minima

        % Convert indices to Toe-Off times
        toe_off_left{file_idx, trial_idx} = toe_off_left_idx;
        toe_off_right{file_idx, trial_idx} = toe_off_right_idx;

        % Calculate Stride Times for Left and Right Legs
        Lheel_strikes = Lheel_strikes_all{file_idx, trial_idx};
        Rheel_strikes = Rheel_strikes_all{file_idx, trial_idx};

        stride_time_left{file_idx, trial_idx} = diff(Lheel_strikes);
        stride_time_right{file_idx, trial_idx} = diff(Rheel_strikes);

        % Calculate Step Times
        min_len = min(length(Lheel_strikes), length(Rheel_strikes)); % Find the smaller array length
        step_time_left_trial = zeros(min_len - 1, 1); % Preallocate based on minimum length
        step_time_right_trial = zeros(min_len - 1, 1); % Preallocate based on minimum length
        
        for i = 1:(min_len - 1)
            step_time_left_trial(i) = abs(Rheel_strikes(i) - Lheel_strikes(i));
            step_time_right_trial(i) = abs(Lheel_strikes(i) - Rheel_strikes(i));
        end
        
        % Assign the calculated step times to the respective cell arrays
        step_time_left{file_idx, trial_idx} = step_time_left_trial;
        step_time_right{file_idx, trial_idx} = step_time_right_trial;

        % Calculate Swing Times
        swing_time_left_trial = nan(length(toe_off_left_idx), 1);
        swing_time_right_trial = nan(length(toe_off_right_idx), 1);

        for i = 1:length(toe_off_left_idx)
            % Find the nearest Lheel_strike after the current Ltoe_off
            next_heel_idx = find(Lheel_strikes > toe_off_left_idx(i), 1);
            if ~isempty(next_heel_idx)
                swing_time_left_trial(i) = Lheel_strikes(next_heel_idx) - toe_off_left_idx(i);
            end
        end

        for i = 1:length(toe_off_right_idx)
            % Find the nearest Rheel_strike after the current Rtoe_off
            next_heel_idx = find(Rheel_strikes > toe_off_right_idx(i), 1);
            if ~isempty(next_heel_idx)
                swing_time_right_trial(i) = Rheel_strikes(next_heel_idx) - toe_off_right_idx(i);
            end
        end

        swing_time_left{file_idx, trial_idx} = swing_time_left_trial;
        swing_time_right{file_idx, trial_idx} = swing_time_right_trial;

        % Display summary for current trial
        fprintf('File %d, Trial %d: Toe-Off, Stride, Step, and Swing Times Calculated.\n', file_idx, trial_idx);
    end
end

% Save results to Workspace
assignin('base', 'toe_off_left', toe_off_left);
assignin('base', 'toe_off_right', toe_off_right);
assignin('base', 'stride_time_left', stride_time_left);
assignin('base', 'stride_time_right', stride_time_right);
assignin('base', 'step_time_left', step_time_left);
assignin('base', 'step_time_right', step_time_right);
assignin('base', 'swing_time_left', swing_time_left);
assignin('base', 'swing_time_right', swing_time_right);

disp('Step 8 completed: Toe-Off, Stride, Step, and Swing Times saved to Workspace.');