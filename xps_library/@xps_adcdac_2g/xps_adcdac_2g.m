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
ucf_constraints_clock  = struct('IOSTANDARD', 'LVDS_25', 'DIFF_TERM', 'TRUE', 'PERIOD', [num2str(2*1000/s.adc_clk_rate),' ns']);
ucf_constraints_term    = struct('IOSTANDARD', 'LVDS_25', 'DIFF_TERM', 'TRUE');
ucf_constraints_noterm = struct('IOSTANDARD', 'LVDS_25');
mhs_constraints = struct('SIGIS','CLK', 'CLK_FREQ',num2str(1e6*s.adc_clk_rate/2));

%ext_ports.DRDY_I_p     = {1  'in' ['adc2g','1','_DRDY_I_p']     ['{',s.hw_sys,'.zdok','1','_p{[20],:}}']                                'vector=false'  mhs_constraints ucf_constraints_clock};
%ext_ports.DRDY_I_n     = {1  'in' ['adc2g','1','_DRDY_I_n']     ['{',s.hw_sys,'.zdok','1','_n{[20],:}}']                                'vector=false'  mhs_constraints ucf_constraints_clock};

%ext_ports.DRDY_Q_p     = {1  'in' ['adc2g','1','_DRDY_Q_p']     ['{',s.hw_sys,'.zdok','1','_p{[40],:}}']                                'vector=false'  mhs_constraints ucf_constraints_clock};
%ext_ports.DRDY_Q_n     = {1  'in' ['adc2g','1','_DRDY_Q_n']     ['{',s.hw_sys,'.zdok','1','_n{[40],:}}']                                'vector=false'  mhs_constraints ucf_constraints_clock};

%data in
adcport1 = [s.hw_sys, '.', 'zdok1'];
adcport0 = [s.hw_sys, '.', 'zdok0'];
ext_ports.data0_p         = {12 'in' ['adc_data0_p'] ['{',adcport1,'_p{[33 24 13 3 32 23 12 2 31 22 11 1],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data0_n         = {12 'in' ['adc_data0_n'] ['{',adcport1,'_n{[33 24 13 3 32 23 12 2 31 22 11 1],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data1_p         = {12 'in' ['adc_data1_p'] ['{',adcport1,'_p{[38 29 18 8 37 28 17 7 36 27 16 6],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data1_n         = {12 'in' ['adc_data1_n'] ['{',adcport1,'_n{[38 29 18 8 37 28 17 7 36 27 16 6],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data2_p         = {12 'in' ['adc_data2_p'] ['{',adcport0,'_p{[33 24 13 3 32 23 12 2 31 22 11 1],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data2_n         = {12 'in' ['adc_data2_n'] ['{',adcport0,'_n{[33 24 13 3 32 23 12 2 31 22 11 1],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data3_p         = {12 'in' ['adc_data3_p'] ['{',adcport0,'_p{[38 29 18 8 37 28 17 7 36 27 16 6],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data3_n         = {12 'in' ['adc_data3_n'] ['{',adcport0,'_n{[38 29 18 8 37 28 17 7 36 27 16 6],:}}'] 'vector=true' struct() ucf_constraints_term};

%sample clocks
ext_ports.data0_smpl_clk_p = {1  'in' ['adc_data0_smpl_clk_p'] ['{',adcport1,'_p{[20],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};
ext_ports.data0_smpl_clk_n = {1  'in' ['adc_data0_smpl_clk_n'] ['{',adcport1,'_n{[20],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};
ext_ports.data1_smpl_clk_p = {1  'in' ['adc_data1_smpl_clk_p'] ['{',adcport1,'_p{[40],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};
ext_ports.data1_smpl_clk_n = {1  'in' ['adc_data1_smpl_clk_n'] ['{',adcport1,'_n{[40],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};
ext_ports.data2_smpl_clk_p = {1  'in' ['adc_data2_smpl_clk_p'] ['{',adcport0,'_p{[20],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};
ext_ports.data2_smpl_clk_n = {1  'in' ['adc_data2_smpl_clk_n'] ['{',adcport0,'_n{[20],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};
ext_ports.data3_smpl_clk_p = {1  'in' ['adc_data3_smpl_clk_p'] ['{',adcport0,'_p{[40],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};
ext_ports.data3_smpl_clk_n = {1  'in' ['adc_data3_smpl_clk_n'] ['{',adcport0,'_n{[40],:}}'] 'vector=false'  mhs_constraints ucf_constraints_clock};

%metadata pins (overrange, sysref)
ext_ports.data0_sys_p     = {2 'in' ['adc_data0_sys_p'] ['{',adcport1,'_p{[4 14],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data0_sys_n     = {2 'in' ['adc_data0_sys_n'] ['{',adcport1,'_n{[4 14],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data1_sys_p     = {2 'in' ['adc_data1_sys_p'] ['{',adcport1,'_p{[9 19],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data1_sys_n     = {2 'in' ['adc_data1_sys_n'] ['{',adcport1,'_n{[9 19],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data2_sys_p     = {2 'in' ['adc_data2_sys_p'] ['{',adcport0,'_p{[4 14],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data2_sys_n     = {2 'in' ['adc_data2_sys_n'] ['{',adcport0,'_n{[4 14],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data3_sys_p     = {2 'in' ['adc_data3_sys_p'] ['{',adcport0,'_p{[9 19],:}}'] 'vector=true' struct() ucf_constraints_term};
ext_ports.data3_sys_n     = {2 'in' ['adc_data3_sys_n'] ['{',adcport0,'_n{[9 19],:}}'] 'vector=true' struct() ucf_constraints_term};

ext_ports.data0_valid_p    = {1 'out' ['adc_data0_vld_p'] ['{',adcport1,'_p{[5],:}}'] 'vector=false' struct() ucf_constraints_term};
ext_ports.data0_valid_n    = {1 'out' ['adc_data0_vld_n'] ['{',adcport1,'_n{[5],:}}'] 'vector=false' struct() ucf_constraints_term};
ext_ports.data1_valid_p    = {1 'out' ['adc_data1_vld_p'] ['{',adcport1,'_p{[26],:}}'] 'vector=false' struct() ucf_constraints_term};
ext_ports.data1_valid_n    = {1 'out' ['adc_data1_vld_n'] ['{',adcport1,'_n{[26],:}}'] 'vector=false' struct() ucf_constraints_term};
ext_ports.data2_valid_p    = {1 'out' ['adc_data2_vld_p'] ['{',adcport0,'_p{[5],:}}'] 'vector=false' struct() ucf_constraints_term};
ext_ports.data2_valid_n    = {1 'out' ['adc_data2_vld_n'] ['{',adcport0,'_n{[5],:}}'] 'vector=false' struct() ucf_constraints_term};
ext_ports.data3_valid_p    = {1 'out' ['adc_data3_vld_p'] ['{',adcport0,'_p{[26],:}}'] 'vector=false' struct() ucf_constraints_term};
ext_ports.data3_valid_n    = {1 'out' ['adc_data3_vld_n'] ['{',adcport0,'_n{[26],:}}'] 'vector=false' struct() ucf_constraints_term};
%ext_ports.DRDY_I_p     = {1  'in' ['adc2g','1','_DRDY_I_p']     ['{',s.hw_sys,'.zdok','1','_p{[20],:}}']                                'vector=false'  mhs_constraints ucf_constraints_clock};

%ext_ports.ADC_ext_in_p = {1  'in' ['adc2g','1','_ADC_ext_in_p'] ['{',s.hw_sys,'.zdok','1','_p{[29],:}}']                                'vector=false'  struct()        ucf_constraints_term};
%ext_ports.ADC_ext_in_n = {1  'in' ['adc2g','1','_ADC_ext_in_n'] ['{',s.hw_sys,'.zdok','1','_n{[29],:}}']                                'vector=false'  struct()        ucf_constraints_term};


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

b = set(b,'misc_ports',misc_ports);
