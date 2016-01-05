function fir_prog_init(blk, varargin)
% By Matt Strader
%
% fir_prog block applies a finite impulse response (FIR) filter
% to data where the data is composed of some number of time
% multiplexed channels. Each channel's data stream can have
% it's own FIR coefficients.  The coefficients are loaded from a
% shared bram one channel at a time.

% Declare default values for arguments
clog('Entering fir_prog_init','trace'); 
disp('fir_prog_init')
defaults = {'nChannels', 256, 'nTaps', 26};
 
% if parameter is changed then only it will redraw otherwise will exit
if same_state(blk, 'defaults', defaults, varargin{:})
    disp('same state')
    return
end
clog('fir_prog_init post same_state','trace'); 
% Checks whether the block selected is correct with this called function.
check_mask_type(blk, 'fir_prog');
 
%Sets the variable to the sub-blocks (scripted ones), also checks whether
%to update or prevent from any update
munge_block(blk, varargin{:});
 
% sets the variable needed
nChannels = get_var('nChannels', 'defaults', defaults, varargin{:});
nTaps = get_var('nTaps', 'defaults', defaults, varargin{:});
 
% Begin redrawing
delete_lines(blk);


% create inputs

reuse_block(blk,'data_in','built-in/Inport',...
                'Port', '1',...
                'Position',[0 100 30 100+20]) ; 


reuse_block(blk,'ch_in','built-in/Inport',...
                'Port', '2',...
                'Position',[0 200 30 200+20]) ; 

reuse_block(blk,'ch_to_write','built-in/Inport',...
                'Port', '6',...
                'Position',[0 400 30 400+20]) ; 
                
reuse_block(blk,'write_coeff','built-in/Inport',...
                'Port', '3',...
                'Position',[0 870 30 870+20]) ; 

reuse_block(blk,'coeff_to_write','built-in/Inport',...
                'Port', '4',...
                'Position',[0 550 30 550+20]) ; 

reuse_block(blk,'tap_to_write','built-in/Inport',...
                'Port', '5',...
                'Position',[0 650 30 650+20]) ; 

sumPos = [500+(nTaps+1)*150 400 500+(nTaps+1)*150+100 30*nTaps+400];
%create output
reuse_block(blk,'data_out','built-in/Outport',...
                'Port', '1',...
                'Position',[620+(nTaps+1)*150 500 620+(nTaps+1)*150+30 500+20]) ;

reuse_block(blk,'ch_out','built-in/Outport',...
                'Port', '2',...
                'Position',[620+(nTaps+1)*150 400 620+(nTaps+1)*150+30 400+20]) ;


reuse_block (blk,'ch_mux','xbsIndex_r4/Mux', 'Position', [100 300 100+30 300+150], 'inputs', '2','latency','1');

reuse_block(blk,'misc_dly','xbsIndex_r4/Delay',...
            'Position',[200 200 200+20 200+20],...
            'latency','3');
reuse_block(blk,'ch_dly','xbsIndex_r4/Delay',...
            'Position',[200 400 200+20 400+20],...
            'latency','2');
reuse_block(blk,'coeff_in_dly','xbsIndex_r4/Delay',...
            'Position',[200 550 200+20 550+20],...
            'latency','3');
reuse_block(blk,'tap_dly','xbsIndex_r4/Delay',...
            'Position',[100 650 100+20 650+20],...
            'latency','1');

%add_line(blk,'data_in/1','data_out/1','autorouting','on');
%add_line(blk,'ch/1','ch_out/1','autorouting','on');

reuse_block(blk, 'not_clear', 'xbsIndex_r4/Inverter', ...
      'latency', '1', 'Position', [100 850 100+50 850+50]);

reuse_block(blk, 'demux', 'utilities/demux', ...
                 'nOutputs',num2str(nTaps),...
                 'Position',[200 700 200+30 700+(40*nTaps)]);


add_latency=3;
reuse_block(blk, 'sum', 'casper_library_misc/adder_tree', ...
    'Position', sumPos, ...
    'n_inputs',num2str(nTaps),'latency',num2str(add_latency), ...
    'adder_imp', 'DSP48','first_stage_hdl','on');

sync_latency = 8;%5 from mult + 3 from bram
reuse_block(blk,'sync_delay','xbsIndex_r4/Delay',...
            'Position',[250+(nTaps+1)*150 200 250+(nTaps+1)*150+30 200+30],...
            'latency',num2str(sync_latency));


bramLatency=6;% delay data enough to demux,address and read from coeff bram block
reuse_block(blk,'data_dly','xbsIndex_r4/Delay',...
            'Position',[200 105 200+30 105+30],...
            'latency',num2str(bramLatency));

add_line(blk,'ch_in/1','misc_dly/1','autorouting','off');
add_line(blk,'ch_to_write/1','ch_mux/3','autorouting','off');
add_line(blk,'write_coeff/1','ch_mux/1','autorouting','off');
add_line(blk,'ch_in/1','ch_mux/2','autorouting','off');
add_line(blk,'ch_mux/1','ch_dly/1','autorouting','off');

add_line(blk,'tap_to_write/1','tap_dly/1','autorouting','off');
add_line(blk,'coeff_to_write/1','coeff_in_dly/1','autorouting','off');
add_line(blk,'misc_dly/1','sync_delay/1','autorouting','off');
add_line(blk,'sum/2','data_out/1','autorouting','off');
add_line(blk,'sync_delay/1','sum/1','autorouting','off');
add_line(blk,'sum/1','ch_out/1','autorouting','off');
add_line(blk,'tap_dly/1','demux/1','autorouting','off');
add_line(blk,'write_coeff/1','not_clear/1','autorouting','off');
add_line(blk,'not_clear/1','demux/2','autorouting','off');
%add_line(blk,'write_coeff/1','demux/2','autorouting','off');

for iTap=1:nTaps
    disp(num2str(iTap));
    iTapLabel = num2str(iTap);
    offset = 50;
    x = 300 + iTap*3*offset;
    y = 400;
    w = 30;
    h = 30;

    bramName = ['bram',num2str(iTap)];
    defaultBramVal = '0';
    reuse_block(blk, bramName, 'xbsIndex_r4/Single Port RAM', ...
            'Position',[430 400+iTap*120 430+50 400+iTap*120+70],...
            'depth', num2str(nChannels), ...
            'initVector',defaultBramVal,...
            'write_mode', 'No Read On Write',...
            'latency','3');

    multname = ['Mult',iTapLabel];
    reuse_block(blk, multname, 'xbsIndex_r4/Mult');
    set_param([blk,'/',multname], ...
            'precision','Full',...
            'latency','5',...
            'use_behavioral_HDL','off',...
            'opt','Speed',...
            'use_embedded','on',...
            'optimum_pipeline','on',...
            'Position', [x+offset y-offset x+offset+40 y-offset+40]);

    if iTap < nTaps
        delayname = ['delay',num2str(iTap)];
        reuse_block(blk,delayname,'casper_library_delays/delay_bram',...
                'Position',[x+2*offset y-2*offset x+2*offset+w y-2*offset+h],...
                'DelayLen',num2str(nChannels),...
                'bram_latency',num2str(2),...
                'use_dsp48','off',...
                'async','off');
    end
    if iTap > 1
        lastdelayname = ['delay',num2str(iTap-1)];
        delayname = ['delay',num2str(iTap)];
        add_line(blk,[lastdelayname,'/1'],[multname,'/1'],'autorouting','off');
        if iTap < nTaps
            add_line(blk,[lastdelayname,'/1'],[delayname,'/1'],'autorouting','off');
        end
    end
    add_line(blk,[multname,'/1'],['sum','/',num2str(nTaps-iTap+2)],'autorouting','off');
    add_line(blk,[bramName,'/1'],[multname,'/2'],'autorouting','off');
    add_line(blk,'ch_dly/1',[bramName,'/1'],'autorouting','off');%addr
    add_line(blk,'coeff_in_dly/1',[bramName,'/2'],'autorouting','off');%data
    add_line(blk,['demux/',num2str(iTap)],[bramName,'/3'],'autorouting','off');%we

end
add_line(blk,'data_in/1','data_dly/1','autorouting','off');
add_line(blk,'data_dly/1','delay1/1','autorouting','off');
add_line(blk,'data_dly/1','Mult1/1','autorouting','off');

% clean out everything else
clean_blocks(blk);
 
%fmtstr = sprintf();
% Printing at the bottom of the block fmtstr = sprintf('Min
% Delay=%d',(n_inputs_bits + bram_latency+1); %
%set_param(blk, 'AttributesFormatString', fmtstr);
 
% Save all the variables just like global variables in C
save_state(blk, 'defaults', defaults, varargin{:});
clog('exiting fir_prog_init','trace'); 
