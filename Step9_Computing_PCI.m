% The Phase Coordination Index (PCI) is a measure of bilateral stepping coordination. 
% It combines both the accuracy and the consistency of the temporal relationship 
% between heel-strike events of the two legs, making it a robust indicator of gait 
% coordination. The calculation method is based on the approach introduced by 
% Plotnik et al. (2007).
% Plotnik, M., Giladi, N., & Hausdorff, J. M. (2007). A new measure for quantifying the bilateral coordination of human gait: effects of aging and Parkinson’s disease. Experimental brain research, 181(4), 561-570.


function [PHI, PHI_ABS, PHI_CV, PCI] = step9_compute_pci_single_leg( ...
    stride_time_right, stride_time_left, step_time_right, step_time_left, ref_leg)
% STEP9_COMPUTE_PCI_SINGLE_LEG
% Compute phase (PHI), PHI_ABS, PHI_CV, and PCI for a single reference leg.
%
% INPUTS:
%   stride_time_right : cell [nFiles x nTrials]
%   stride_time_left  : cell [nFiles x nTrials]
%   step_time_right   : cell [nFiles x nTrials]
%   step_time_left    : cell [nFiles x nTrials]
%   ref_leg           : 'R' or 'L'  (reference leg)
%
% OUTPUTS (all are cell [nFiles x nTrials]):
%   PHI      : vector of phase values per trial (degrees, wrapped to [0,180])
%   PHI_ABS  : scalar per trial = mean(|PHI - 180|)
%   PHI_CV   : scalar per trial = 100 * std(PHI)/mean(PHI)
%   PCI      : scalar per trial = PHI_CV + (PHI_ABS/180)*100
%
% NOTES:
%   - Skips trials with missing/empty data and leaves corresponding cells empty.
%   - Does not write to base workspace; returns outputs directly.

    % ---------- validation ----------
    if nargin < 5 || ~ismember(ref_leg, {'R','L'})
        error('ref_leg must be ''R'' or ''L''.');
    end
    req = {stride_time_right, stride_time_left, step_time_right, step_time_left};
    if any(cellfun(@(c) ~iscell(c), req))
        error('All time inputs must be cell arrays [nFiles x nTrials].');
    end

    nFiles  = size(stride_time_right, 1);
    nTrials = size(stride_time_right, 2);

    % ---------- preallocate ----------
    PHI     = cell(nFiles, nTrials);
    PHI_ABS = cell(nFiles, nTrials);
    PHI_CV  = cell(nFiles, nTrials);
    PCI     = cell(nFiles, nTrials);

    fprintf('Calculating Phase (phi), phi_ABS, phi_CV, and PCI for leg = %s ...\n', ref_leg);

    for f = 1:nFiles
        for t = 1:nTrials

            % fetch series according to reference leg
            if ref_leg == 'R'
                stride_ref = stride_time_right{f,t};
                step_A     = step_time_left{f,t};   % opposite leg
                step_B     = step_time_right{f,t};  % same leg (for min-length checks)
            else % 'L'
                stride_ref = stride_time_left{f,t};
                step_A     = step_time_right{f,t};  % opposite leg
                step_B     = step_time_left{f,t};   % same leg (for min-length checks)
            end

            % check availability
            if isempty(stride_ref) || isempty(step_A) || isempty(step_B)
                fprintf('Skipping file %d, trial %d: missing stride/step series.\n', f, t);
                continue;
            end

            % align lengths conservatively
            m = min([numel(stride_ref), numel(step_A), numel(step_B)]);
            if m < 1
                fprintf('Skipping file %d, trial %d: insufficient paired lengths.\n', f, t);
                continue;
            end
            stride_ref = stride_ref(1:m);
            step_A     = step_A(1:m);

            % ---- PHI computation (wrap to [0,180]) ----
            phi = (360 .* step_A) ./ stride_ref;   % definition: opposite step / reference stride
            phi = mod(phi, 360);
            idx = (phi > 180);
            phi(idx) = 360 - phi(idx);

            % ---- PHI_ABS, PHI_CV, PCI ----
            phi_abs = mean(abs(phi - 180), 'omitnan');  % distance from anti-phase
            mu      = mean(phi, 'omitnan');
            sig     = std(phi, 0, 'omitnan');
            phi_cv  = 100 * (sig / mu);
            pci_val = phi_cv + (phi_abs/180)*100;

            % store
            PHI{f,t}     = phi;
            PHI_ABS{f,t} = phi_abs;
            PHI_CV{f,t}  = phi_cv;
            PCI{f,t}     = pci_val;

            fprintf('File %d, Trial %d: %s_PCI = %.2f\n', f, t, ref_leg, pci_val);
        end
    end

    disp('Single-leg PHI and PCI computations completed.');
end

