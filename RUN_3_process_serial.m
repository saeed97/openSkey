%% Startup
startup_opensky

%% Inputs
% Output of RUN_3_findFiles.sh
inFilesZip = [getenv('AEM_DIR_OPENSKY') filesep 'output' filesep 'files_zip_output_2_archive_llsc_' '.txt'];

% Directory roots
unixRoot = '/mnt/d/GitHub/Low_Altitude_Encounter_Model';
winRoot = getenv('AEM_DIR_OPENSKY');

% Random seed
seed = 42;

%% Set random seed
rng(seed,'twister');

%% Read in the output of RUN_3_findFiles.sh
fid = fopen(inFilesZip,'r');
[inFiles] = textscan(fid,'%s','HeaderLines',0,'EndOfLine','\n','TextType','string');
fclose(fid);
inFiles = inFiles{1};

%% Accomodate 
% RUN_3_findFiles.sh is assumed to run in shell script, so we this code is
% being run on MATLAB, we need to change the path
if ispc
    inFiles = strrep(inFiles,unixRoot,strrep(winRoot,filesep,'/'));
end

%% For load balancing, randomize order of inFiles
% We don't want one node to get all "easy" Balloon tasks and another node
% to get "hard" FixedWingMultiEngine tasks
inFiles = inFiles(randperm(numel(inFiles)));

%% Make output directories
outDirs = strings(size(inFiles));
for i=1:1:numel(inFiles)
    outDirs(i) = strrep(inFiles{i}(1:end-4),'2_archive','3_process');
    if ~exist(outDirs(i) ,'dir');mkdir(outDirs(i) ); end
end

%% Iterate over files
timeProcess_s = nan(numel(inFiles),1);
Pid = 1; % always one when serial
for i=1:1:numel(inFiles)
    % Get aircraft type
    % Assume directory structure from RUN_0_*
    C = strsplit(inFiles(i),'/');
    inYear = C(end-3);
    acType = C(end-2);
    
    % Outlier thresholds dependent upon aircraft type
    [maxAlt_ft_msl,outlierSpeed_kt,outlierTurnRate_deg_s,outlierVertRate_ft_s] = getOutlierThersholds(acType);
    
    % Execute
    tic
    processSplitClean_3(inFiles(i),'outDir',outDirs(i),...
        'maxAlt_ft_msl',maxAlt_ft_msl,...
        'outlierSpeed_kt',outlierSpeed_kt,'outlierTurnRate_deg_s',outlierTurnRate_deg_s,'outlierVertRate_ft_s',outlierVertRate_ft_s,...
        'isPlotSeg',false,'isPlotRates',false,'isVerbose',false);
    timeProcess_s(i) = toc;
    
    % Display status
    fprintf('i = %i, n = %i, year = %s, acType = %s, inFile = %s\n',i,numel(inFiles),inYear,acType,inFiles(i));
end

%% Save
save([getenv('AEM_DIR_OPENSKY') filesep 'output' filesep '3_process_meta' filesep sprintf('3_metadata_%i.mat',Pid)],'inFilesZip','seed','inFiles','outDirs','timeProcess_s','Pid');