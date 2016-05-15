%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
%   Center for Astronomy Signal Processing and Electronics Research           %
%   http://seti.ssl.berkeley.edu/casper/                                      %
%   Copyright (C) 2006 University of California, Berkeley                     %
%                                                                             %
%   This program is free software; you can redistribute it and/or modify      %
%   it under the terms of the GNU General Public License as published by      %
%   the Free Software Foundation; either version 2 of the License, or         %
%   (at your option) any later version.                                       %
%                                                                             %
%   This program is distributed in the hope that it will be useful,           %
%   but WITHOUT ANY WARRANTY; without even the implied warranty of            %
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             %
%   GNU General Public License for more details.                              %
%                                                                             %
%   You should have received a copy of the GNU General Public License along   %
%   with this program; if not, write to the Free Software Foundation, Inc.,   %
%   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.               %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make sure this is an XPS object
function b = xps_adcdac_2g_ctrl(blk_obj)
disp('calling xps_adcdac_2g_ctrl!');
if ~isa(blk_obj,'xps_block')
    error('xps_adcdac_2g_ctrl class requires a xps_block class object');
end
% Then check that it's the right type
if ~strcmp(get(blk_obj,'type'),'xps_adcdac_2g_ctrl')
    error(['Wrong XPS block type: ',get(blk_obj,'type')]);
end
disp('.1');
disp('.1');

blk_name = get(blk_obj,'simulink_name');
xsg_obj = get(blk_obj,'xsg_obj');

s.hw_sys = get(xsg_obj,'hw_sys');

% Get the mask parameters we need to know
s.clk_sys = get(xsg_obj,'clk_src');
disp('.1');
  
  
b = class(s,'xps_adcdac_2g_ctrl',blk_obj);

% ip name & version
b = set(b,'ip_name','adcdac_2g_ctrl');
b = set(b,'ip_version','1.00.a');

disp('.1');
%b = set(b,'parameters',parameters);


n_adc_samples_per_fabric_cycle = 8;


% external ports
ucf_constraints_term    = struct('IOSTANDARD', 'LVDS_25', 'DIFF_TERM', 'TRUE');
ucf_constraints_noterm = struct('IOSTANDARD', 'LVDS_25');
disp('.1');

%data in
adcport1 = [s.hw_sys, '.', 'zdok1'];
adcport0 = [s.hw_sys, '.', 'zdok0'];

%first 3 bits in each are (valid,sysref,overrange)
ext_ports.zdok_tx_data_p         = {1 'out' ['adc_ctrl_tx_data_p'] ['{',adcport1,'_p{[10],:}}'] 'vector=false' struct() ucf_constraints_term};
ext_ports.zdok_tx_data_n         = {1 'out' ['adc_ctrl_tx_data_n'] ['{',adcport1,'_n{[10],:}}'] 'vector=false' struct() ucf_constraints_term};

ext_ports.zdok_rx_data_p         = {1 'in' ['adc_ctrl_rx_data_p'] ['{',adcport1,'_p{[30],:}}'] 'vector=false' struct() ucf_constraints_term};
ext_ports.zdok_rx_data_n         = {1 'in' ['adc_ctrl_rx_data_n'] ['{',adcport1,'_n{[30],:}}'] 'vector=false' struct() ucf_constraints_term};


b = set(b,'ext_ports',ext_ports);

% Add ports not explicitly provided in the yellow block

%clock from fpga 
misc_ports.fpga_clk       = {1 'in'  get(xsg_obj,'clk_src')};
%100 MHz clock for the uart
%misc_ports.sys_clk       = {1 'in'  'sys_clk'};

b = set(b,'misc_ports',misc_ports);

disp('done calling xps_adcdac_2g_ctrl!');
