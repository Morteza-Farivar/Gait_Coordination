Define Helper Function for Hilbert Transform

% Function to compute the phase angle of a signal using Hilbert Transform
% Input:
%   signal - Numeric array (joint angle or motion data in degrees)
% Output:
%   phase_angle - Phase angles in degrees
function phase_angle = Hilbert_PA(signal)
    % Validate input
    if ~isnumeric(signal) || isempty(signal)
        error('Input signal must be a non-empty numeric array.');
    end

    % Check for NaN values and warn
    if any(isnan(signal))
        warning('Input signal contains NaN values. These will be ignored during Hilbert Transform.');
    end

    % Center the signal around zero before Hilbert Transform
    centered_signal = signal - mean(signal, 'omitnan'); % Ignore NaNs during centering

    % Apply Hilbert Transform to compute phase angles
    analytic_signal = hilbert(centered_signal); % Compute analytic signal

    % Compute phase angle in degrees
    phase_angle = rad2deg(angle(analytic_signal)); % Convert radians to degrees
end