model = 'Bidirectional_DC_DC';
load_system(model);

% Enable logging on the Scope
set_param([model '/Scope'], 'DataLogging', 'on', 'DataLoggingVariableName', 'ScopeData', 'DataLoggingSaveFormat', 'Dataset');
save_system(model);

% Run the simulation
out = sim(model);

% Extract the data
try
    scopeData = out.ScopeData;
catch
    scopeData = evalin('base', 'ScopeData'); % Fallback
end

% Create a hidden figure
fig = figure('Visible', 'off');

% The Mux combines the signals into a single element with multiple columns
ts = scopeData.getElement(1).Values;
plot(ts.Time, ts.Data);

title('Bidirectional DC-DC Converter Simulation Results');
xlabel('Time (s)');
ylabel('Voltage (V)');
legend('Output Voltage (VH)', 'Input Voltage (VL)', 'Location', 'best');
grid on;

% Save to PNG
saveas(fig, 'simulation_result.png');
disp('Successfully generated simulation_result.png!');
