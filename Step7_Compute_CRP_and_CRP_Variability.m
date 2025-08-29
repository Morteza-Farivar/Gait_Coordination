%% Step 7: Compute CRP and CRP Variability for All Gait Cycles

% Continuous Relative Phase (CRP) is a nonlinear metric that quantifies the 
% dynamic coordination between two oscillating segments across the gait cycle. 
% CRP Variability reflects the consistency of this coordination across repeated 
% cycles, offering insight into neuromechanical control strategies. 
% The method applied here follows the approach described by Lamb & Stöckl (2014).
% Lamb, P. F., & Stöckl, M. (2014). On the use of continuous relative phase: Review of current approaches and outline for a new standard. Clinical Biomechanics, 29(5), 484-493.


% Validate inputs
if ~exist('phase_angles', 'var') || isempty(phase_angles)
    error('Phase angles are missing. Ensure Step 7 runs successfully before Step 8.');
end

% Define the segment couplings and axes for processing
segment_couplings = {
    'L_thigh', 'L_shank'; ...
    'L_shank', 'L_foot'; ...
    'R_thigh', 'R_shank'; ...
    'R_shank', 'R_foot'; ...
    'R_thigh', 'pelvis'; ...
    'L_thigh', 'pelvis'; ...
    'trunk', 'pelvis'
};
axes = {'X', 'Y', 'Z'};

% Initialize storage for CRP and variability for all files and trials
num_files = size(phase_angles.(segment_couplings{1, 1}).(axes{1}), 1); % Number of files
num_trials = size(phase_angles.(segment_couplings{1, 1}).(axes{1}), 2); % Number of trials
crp_all = struct();
crp_variability = struct();

for coupling_idx = 1:size(segment_couplings, 1)
    for ax = 1:numel(axes)
        coupling_name = [segment_couplings{coupling_idx, 1}, '_', segment_couplings{coupling_idx, 2}];
        crp_all.(coupling_name).(axes{ax}) = cell(num_files, num_trials);
        crp_variability.(coupling_name).(axes{ax}) = cell(num_files, num_trials);
    end
end

disp('Computing CRP and Variability for all gait cycles...');

% Loop through files and trials
for file_idx = 1:num_files
    for trial_idx = 1:num_trials
        % Check if phase angle data exists for this trial
        if isempty(phase_angles.(segment_couplings{1, 1}).(axes{1}){file_idx, trial_idx})
            fprintf('Skipping file %d, trial %d: No phase angle data.\n', file_idx, trial_idx);
            continue;
        end

        % Loop through segment couplings and axes
        for coupling_idx = 1:size(segment_couplings, 1)
            for ax = 1:numel(axes)
                % Extract distal and proximal segments
                distal = segment_couplings{coupling_idx, 1};
                proximal = segment_couplings{coupling_idx, 2};

                % Extract phase angles for the distal and proximal segments
                distal_angle = phase_angles.(distal).(axes{ax}){file_idx, trial_idx};
                proximal_angle = phase_angles.(proximal).(axes{ax}){file_idx, trial_idx};

                % Check for extreme values in phase angles
                if any(abs([distal_angle{:}]) > 360) || any(abs([proximal_angle{:}]) > 360)
                    warning('Extreme phase angle values detected in file %d, trial %d, segment %s, axis %s. Skipping this trial.\n', ...
                            file_idx, trial_idx, distal, axes{ax});
                    continue;
                end

                % Compute CRP for all gait cycles
                num_cycles = numel(distal_angle);
                crp_cycles = zeros(num_cycles, 100); % Preallocate for normalized CRP

                for cycle_idx = 1:num_cycles
                    % Compute CRP: distal - proximal
                    crp_cycles(cycle_idx, :) = ...
                        distal_angle{cycle_idx} - proximal_angle{cycle_idx};
                end

                % Wrap CRP angles to [-180, 180] degrees
                crp_cycles_deg = mod(crp_cycles + 180, 360) - 180;

                % Store CRP for all cycles without averaging
                coupling_name = [distal, '_', proximal];
                crp_all.(coupling_name).(axes{ax}){file_idx, trial_idx} = crp_cycles_deg;

                % Compute and store CRP Variability (standard deviation)
                crp_avg = mean(crp_cycles_deg, 1, 'omitnan'); % Compute mean for each point
                crp_variability.(coupling_name).(axes{ax}){file_idx, trial_idx} = ...
                    std(crp_cycles_deg - crp_avg, 0, 1, 'omitnan'); % Standard deviation from the mean
            end
        end
    end
end

disp('CRP and Variability computation completed.');

% Save CRP data and variability to Workspace
assignin('base', 'crp_all', crp_all);
assignin('base', 'crp_variability', crp_variability);


disp('Step 7 completed: CRP and Variability data saved successfully.');
