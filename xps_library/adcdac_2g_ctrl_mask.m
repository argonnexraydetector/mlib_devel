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

disp('calling adcdac_2g_ctrl_mask');
myname = gcb; 
set_param(myname, 'LinkStatus', 'inactive');

gateway_outs = find_system(gcb,'searchdepth',1,'FollowLinks', 'on','lookundermasks','all','masktype','Xilinx Gateway Out Block');
gateway_ins = find_system(gcb,'searchdepth',1,'FollowLinks', 'on','lookundermasks','all','masktype','Xilinx Gateway In Block');
gateways = [gateway_outs;gateway_ins];

name_index = 1;
gw_name_list = {};

gw_name_list{name_index} = 'user_tx_rst';
name_index = name_index + 1;
gw_name_list{name_index} = 'user_rx_rst';
name_index = name_index + 1;
gw_name_list{name_index} = 'user_tx_data';
name_index = name_index + 1;
gw_name_list{name_index} = 'user_tx_val';
name_index = name_index + 1;
gw_name_list{name_index} = 'user_tx_full';
name_index = name_index + 1;
gw_name_list{name_index} = 'user_rx_full';
name_index = name_index + 1;
gw_name_list{name_index} = 'user_rx_data';
name_index = name_index + 1;
gw_name_list{name_index} = 'user_rx_val';
name_index = name_index + 1;

for i =1:length(gateways)
    gw_name_found = 0;
    gw = gateways{i};
    gw_name = get_param(gw,'Name');

    for name_item=gw_name_list
        if regexp(gw_name,['(',name_item{:},')$'])
            toks = regexp(gw_name,['(',name_item{:},')$'],'tokens');
            set_param(gw,'Name',clear_name([gcb,'_',toks{1}{1}]));
            gw_name_found = 1;
        end
    end

    if gw_name_found == 0
        error(['Unkown gateway name: ',gw]);
    end
end
disp('done calling adcdac_2g_ctrl_mask');
