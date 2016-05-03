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
function b = xps_adcdac_2g(blk_obj)
disp('calling xps_adcdac_2g!');
if ~isa(blk_obj,'xps_block')
    error('xps_adcdac_2g class requires a xps_block class object');
end
% Then check that it's the right type
if ~strcmp(get(blk_obj,'type'),'xps_adcdac_2g')
    error(['Wrong XPS block type: ',get(blk_obj,'type')]);
end

blk_name = get(blk_obj,'simulink_name');
xsg_obj = get(blk_obj,'xsg_obj');

s.hw_sys = get(xsg_obj,'hw_sys');
s.adc_str = ['adc', '0'];

% Get the mask parameters we need to know
s.adc_clk_rate = eval_param(blk_name,'adc_clk_rate');
s.clk_sys = get(xsg_obj,'clk_src');
  
  
b = class(s,'xps_adcdac_2g',blk_obj);

% ip name & version
b = set(b,'ip_name','adcdac_2g_interface');
b = set(b,'ip_version','1.00.a');

%b = set(b,'parameters',parameters);


n_adc_samples_per_fabric_cycle = 8


% external ports
ucf_constraints_clock  = struct('IOSTANDARD', 'LVDS_25', 'DIFF_TERM', 'TRUE', 'PERIOD', '8 ns');
ucf_constraints_term    = struct('IOSTANDARD', 'LVDS_25', 'DIFF_TERM', 'TRUE');
ucf_constraints_noterm = struct('IOSTANDARD', 'LVDS_25');
mhs_constraints = struct('SIGIS','CLK', 'CLK_FREQ','125000000');

%data in
adcport1 = [s.hw_sys, '.', 'zdok1'];
adcport0 = [s.hw_sys, '.', 'zdok0'];
adcport_sync = [s.hw_sys, '.', 'sync_in'];
adcport_sync_out = [s.hw_sys, '.', 'sync_out'];

ext_ports.valid_p         = {1 'in' ['adc_valid_p'] ['{',adcport1,'_p{[5],:}}'] 'vector=false' struct() ucf_constraints_term};
ext_ports.valid_n         = {1 'in' ['adc_valid_n'] ['{',adcport1,'_n{[5],:}}'] 'vector=false' struct() ucf_constraints_term};

%last 2 bits in each are (sysref,overrange)
ext_ports.data0_p         = {12 'in' ['adc_data0_p'] ['{',adcport1,'_p{[1 21 11 31 2 22 12 32 3 23 13 33],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data0_n         = {12 'in' ['adc_data0_n'] ['{',adcport1,'_n{[1 21 11 31 2 22 12 32 3 23 13 33],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.info0_p         = {2 'in' ['adc_info0_p'] ['{',adcport0,'_p{[1 13],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.info0_n         = {2 'in' ['adc_info0_n'] ['{',adcport0,'_n{[1 13],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data1_p         = {12 'in' ['adc_data1_p'] ['{',adcport1,'_p{[6 26 16 36 7 27 17 37 8 28 18 38],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data1_n         = {12 'in' ['adc_data1_n'] ['{',adcport1,'_n{[6 26 16 36 7 27 17 37 8 28 18 38],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.info1_p         = {2 'in' ['adc_info1_p'] ['{',adcport0,'_p{[29 11],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.info1_n         = {2 'in' ['adc_info1_n'] ['{',adcport0,'_n{[29 11],:}}'] 'vector=true' struct() ucf_constraints_term};

%ext_ports.data2_p         = {14 'in' ['adc_data2_p'] ['{',adcport0,'_p{[1 9 11 31 2 29 12 32 5 15 13 33],:}}'] 'vector=true' struct() ucf_constraints_term};
%ext_ports.data2_n         = {14 'in' ['adc_data2_n'] ['{',adcport0,'_n{[1 9 11 31 2 29 12 32 5 15 13 33],:}}'] 'vector=true' struct() ucf_constraints_term};
%ext_ports.info2_p         = {14 'in' ['adc_data2_p'] ['{',adcport0,'_p{[4 24],:}}'] 'vector=true' struct() ucf_constraints_term};
%ext_ports.info2_n         = {14 'in' ['adc_data2_n'] ['{',adcport0,'_n{[4 24],:}}'] 'vector=true' struct() ucf_constraints_term};

%ext_ports.data2_p         = {12 'in' ['adc_data2_p'] ['{',adcport1,'_p{[4 24 14 34 29 9 15 39 10 35 30 19],:}}'] 'vector=true' struct() ucf_constraints_term};
%ext_ports.data2_n         = {12 'in' ['adc_data2_n'] ['{',adcport1,'_n{[4 24 14 34 29 9 15 39 10 35 30 19],:}}'] 'vector=true' struct() ucf_constraints_term};

%zdok0 data2[4,5,7,8,10,11]
ext_ports.data2z0_p         = {6 'in' ['adc_data2z0_p'] ['{',adcport0,'_p{[14 5 32 31 9 29],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data2z0_n         = {6 'in' ['adc_data2z0_n'] ['{',adcport0,'_n{[14 5 32 31 9 29],:}}'] 'vector=true' struct() ucf_constraints_term};
%zdok1 data2[0,1,2,3,6,9]
ext_ports.data2z1_p         = {6 'in' ['adc_data2z1_p'] ['{',adcport1,'_p{[4 24 14 34 15 35],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data2z1_n         = {6 'in' ['adc_data2z1_n'] ['{',adcport1,'_n{[4 24 14 34 15 35],:}}'] 'vector=true' struct() ucf_constraints_term};

ext_ports.info2_p         = {2 'in' ['adc_info2_p'] ['{',adcport0,'_p{[4 24],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.info2_n         = {2 'in' ['adc_info2_n'] ['{',adcport0,'_n{[4 24],:}}'] 'vector=true' struct() ucf_constraints_term};

ext_ports.data3_p         = {12 'in' ['adc_data3_p'] ['{',adcport0,'_p{[6 26 16 36 7 27 17 37 8 28 19 11],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data3_n         = {12 'in' ['adc_data3_n'] ['{',adcport0,'_n{[6 26 16 36 7 27 17 37 8 28 19 11],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.info3_p         = {2 'in' ['adc_info3_p'] ['{',adcport0,'_p{[21 22],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.info3_n         = {2 'in' ['adc_info3_n'] ['{',adcport0,'_n{[21 22],:}}'] 'vector=true' struct() ucf_constraints_term};

%sample clocks
ext_ports.data0_smpl_clk_p = {1  'in' ['adc_data0_smpl_clk_p'] ['{',adcport0,'_p{[20],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};
ext_ports.data0_smpl_clk_n = {1  'in' ['adc_data0_smpl_clk_n'] ['{',adcport0,'_n{[20],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};
%ext_ports.data1_smpl_clk_p = {1  'in' ['adc_data1_smpl_clk_p'] ['{',adcport1,'_p{[40],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};
%ext_ports.data1_smpl_clk_n = {1  'in' ['adc_data1_smpl_clk_n'] ['{',adcport1,'_n{[40],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};
%ext_ports.data2_smpl_clk_p = {1  'in' ['adc_data2_smpl_clk_p'] ['{',adcport0,'_p{[20],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};
%ext_ports.data2_smpl_clk_n = {1  'in' ['adc_data2_smpl_clk_n'] ['{',adcport0,'_n{[20],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};
%ext_ports.data3_smpl_clk_p = {1  'in' ['adc_data3_smpl_clk_p'] ['{',adcport0,'_p{[40],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};
%ext_ports.data3_smpl_clk_n = {1  'in' ['adc_data3_smpl_clk_n'] ['{',adcport0,'_n{[40],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};

%PPS coming through the sma sync in port
ext_ports.sync_pps_p = {1  'in' ['adc_sync_pps_p'] ['{',adcport_sync,'_p{[1],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};
ext_ports.sync_pps_n = {1  'in' ['adc_sync_pps_n'] ['{',adcport_sync,'_n{[1],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};


%handshake from roach enabling ADC streams
ext_ports.data0_rdy_p    = {1 'out' ['adc_data0_rdy_p'] ['{',adcport1,'_p{[25],:}}'] 'vector=false' struct() ucf_constraints_term};
ext_ports.data0_rdy_n    = {1 'out' ['adc_data0_rdy_n'] ['{',adcport1,'_n{[25],:}}'] 'vector=false' struct() ucf_constraints_term};
%ext_ports.data1_rdy_p    = {1 'out' ['adc_data1_rdy_p'] ['{',adcport1,'_p{[35],:}}'] 'vector=false' struct() ucf_constraints_term};
%ext_ports.data1_rdy_n    = {1 'out' ['adc_data1_rdy_n'] ['{',adcport1,'_n{[35],:}}'] 'vector=false' struct() ucf_constraints_term};
%ext_ports.data2_rdy_p    = {1 'out' ['adc_data2_rdy_p'] ['{',adcport0,'_p{[25],:}}'] 'vector=false' struct() ucf_constraints_term};
%ext_ports.data2_rdy_n    = {1 'out' ['adc_data2_rdy_n'] ['{',adcport0,'_n{[25],:}}'] 'vector=false' struct() ucf_constraints_term};
%ext_ports.data3_rdy_p    = {1 'out' ['adc_data3_rdy_p'] ['{',adcport0,'_p{[35],:}}'] 'vector=false' struct() ucf_constraints_term};
%ext_ports.data3_rdy_n    = {1 'out' ['adc_data3_rdy_n'] ['{',adcport0,'_n{[35],:}}'] 'vector=false' struct() ucf_constraints_term};

ext_ports.sync_out_p    = {1 'out' ['adc_sync_out_p'] ['{',adcport_sync_out,'_p{[1],:}}'] 'vector=false' struct() ucf_constraints_term};
ext_ports.sync_out_n    = {1 'out' ['adc_sync_out_n'] ['{',adcport_sync_out,'_n{[1],:}}'] 'vector=false' struct() ucf_constraints_term};

b = set(b,'ext_ports',ext_ports);

% Add ports not explicitly provided in the yellow block

%clock from fpga (used if clock is not set to adc_clk in XSG)
%misc_ports.fpga_clk       = {1 'in'  get(xsg_obj,'clk_src')};

%clocks to send to fpga
if  strfind(s.clk_sys,'adc')
  misc_ports.adc_clk_out    = {1 'out' [s.adc_str,'_clk']};
  misc_ports.adc_clk90_out    = {1 'out' [s.adc_str,'_clk90']};
  misc_ports.adc_clk180_out    = {1 'out' [s.adc_str,'_clk180']};
  misc_ports.adc_clk270_out    = {1 'out' [s.adc_str,'_clk270']};
end

%lock for clock manager
misc_ports.adc_mmcm_locked = {1 'out' [s.adc_str, '_mmcm_locked']};
misc_ports.sys_clk       = {1 'in'  'sys_clk'};

b = set(b,'misc_ports',misc_ports);

disp('done calling xps_adcdac_2g!');
