model = 'Bidirectional_DC_DC';
load_system(model);

% Add new Voltage Measurement block
add_block('powerlib/Measurements/Voltage Measurement', [model '/VL_Measure'], 'Position', [100, 250, 120, 280]);

% Get port handles
ph_VL = get_param([model '/VL'], 'PortHandles');
ph_VLM = get_param([model '/VL_Measure'], 'PortHandles');
ph_Scope = get_param([model '/Scope'], 'PortHandles');
ph_VH = get_param([model '/VH_Measure'], 'PortHandles');

% Connect VL_Measure across VL
add_line(model, ph_VL.RConn(1), ph_VLM.LConn(1), 'autorouting', 'smart');
add_line(model, ph_VL.LConn(1), ph_VLM.LConn(2), 'autorouting', 'smart');

% Add a Mux block to combine the signals for the Scope
add_block('simulink/Signal Routing/Mux', [model '/Mux'], 'Position', [610, 160, 615, 220]);
set_param([model '/Mux'], 'Inputs', '2', 'DisplayOption', 'bar');
ph_Mux = get_param([model '/Mux'], 'PortHandles');

% Find and delete the existing line between VH_Measure and Scope
line_out = get_param(ph_VH.Outport(1), 'Line');
if line_out ~= -1
    delete_line(line_out);
end

% Connect VH_Measure to Mux Input 1
add_line(model, ph_VH.Outport(1), ph_Mux.Inport(1), 'autorouting', 'smart');

% Connect VL_Measure to Mux Input 2
add_line(model, ph_VLM.Outport(1), ph_Mux.Inport(2), 'autorouting', 'smart');

% Connect Mux to Scope
add_line(model, ph_Mux.Outport(1), ph_Scope.Inport(1), 'autorouting', 'smart');

% Name the signals so they show up in the Scope legend
set_param(ph_VH.Outport(1), 'Name', 'Output Voltage (VH)');
set_param(ph_VLM.Outport(1), 'Name', 'Input Voltage (VL)');

save_system(model);
disp('Successfully added input measurement and Mux!');
