model = 'Bidirectional_DC_DC';
load_system(model);

% Helper function to get port handles
get_ph = @(block) get_param([model '/' block], 'PortHandles');

ph_VL = get_ph('VL');
ph_Cin = get_ph('Cin');
ph_L = get_ph('L');
ph_S1 = get_ph('S1');
ph_S2 = get_ph('S2');
ph_Co = get_ph('Co');
ph_Ro = get_ph('Ro');
ph_VH = get_ph('VH_Measure');
ph_Scope = get_ph('Scope');
ph_P1 = get_ph('Pulse_S1');
ph_P2 = get_ph('Pulse_S2');

% Connect Ground (Negative) Path
% VL(-) to Cin(bottom)
add_line(model, ph_VL.LConn(1), ph_Cin.RConn(1), 'autorouting', 'smart');
% Cin(bottom) to S2(Source)
add_line(model, ph_Cin.RConn(1), ph_S2.RConn(1), 'autorouting', 'smart');
% S2(Source) to Co(bottom)
add_line(model, ph_S2.RConn(1), ph_Co.RConn(1), 'autorouting', 'smart');
% Co(bottom) to Ro(bottom)
add_line(model, ph_Co.RConn(1), ph_Ro.RConn(1), 'autorouting', 'smart');
% Ro(bottom) to VH_Measure(-)
add_line(model, ph_Ro.RConn(1), ph_VH.LConn(2), 'autorouting', 'smart');

% Connect Positive Path (Low Voltage Side)
% VL(+) to Cin(top)
add_line(model, ph_VL.RConn(1), ph_Cin.LConn(1), 'autorouting', 'smart');
% Cin(top) to L(left)
add_line(model, ph_Cin.LConn(1), ph_L.LConn(1), 'autorouting', 'smart');

% Connect Inductor to MOSFETs
% L(right) to S1(Source)
add_line(model, ph_L.RConn(1), ph_S1.RConn(1), 'autorouting', 'smart');
% S1(Source) to S2(Drain)
add_line(model, ph_S1.RConn(1), ph_S2.LConn(1), 'autorouting', 'smart');

% Connect Positive Path (High Voltage Side)
% S1(Drain) to Co(top)
add_line(model, ph_S1.LConn(1), ph_Co.LConn(1), 'autorouting', 'smart');
% Co(top) to Ro(top)
add_line(model, ph_Co.LConn(1), ph_Ro.LConn(1), 'autorouting', 'smart');
% Ro(top) to VH_Measure(+)
add_line(model, ph_Ro.LConn(1), ph_VH.LConn(1), 'autorouting', 'smart');

% Connect Controls and Measurements
% Pulse_S1 to S1(g)
add_line(model, ph_P1.Outport(1), ph_S1.Inport(1), 'autorouting', 'smart');
% Pulse_S2 to S2(g)
add_line(model, ph_P2.Outport(1), ph_S2.Inport(1), 'autorouting', 'smart');
% VH_Measure(v) to Scope
add_line(model, ph_VH.Outport(1), ph_Scope.Inport(1), 'autorouting', 'smart');

% Add terminators for Mosfet measurement ports to avoid warnings
add_block('simulink/Sinks/Terminator', [model '/Term1'], 'Position', [370, 100, 390, 120]);
add_block('simulink/Sinks/Terminator', [model '/Term2'], 'Position', [370, 230, 390, 250]);
ph_T1 = get_ph('Term1');
ph_T2 = get_ph('Term2');
add_line(model, ph_S1.Outport(1), ph_T1.Inport(1), 'autorouting', 'smart');
add_line(model, ph_S2.Outport(1), ph_T2.Inport(1), 'autorouting', 'smart');

save_system(model);
disp('Successfully connected the circuit!');
