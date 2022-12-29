clear;

%%
%  URLs, directories, and file names
%
libRoot = 'libraries';
% MatConvNet
matConvNet.URL = 'https://github.com/vlfeat/matconvnet/archive/refs/tags/v1.0-beta25.zip';
matConvNet.zip = 'matconvnet-1.0-beta25.zip';
matConvNet.dir = 'matconvnet-1.0-beta25';
% OpenFace
openFace.URL = 'https://github.com/TadasBaltrusaitis/OpenFace/archive/refs/tags/OpenFace_2.2.0.zip';
openFace.zip = 'OpenFace-OpenFace_2.2.0.zip';
openFace.dir = 'OpenFace-OpenFace_2.2.0';
% OpenFace models
openFace.modelDir = fullfile(libRoot, openFace.dir, 'matlab_version', 'models', 'cen');
openFace.models = {
	'cen_patches_0.25_general.mat', 'https://www.dropbox.com/sh/o8g1530jle17spa/AADl5i_cbYHQIW3RLqe99jsCa/cen_patches_0.25_general.mat?dl=1';
	'cen_patches_0.25_menpo.mat',   'https://www.dropbox.com/sh/o8g1530jle17spa/AADsYzX8IYLQJDwfHhF2ZIDEa/cen_patches_0.25_menpo.mat?dl=1';
	'cen_patches_0.25_of.mat',      'https://www.dropbox.com/sh/o8g1530jle17spa/AABNaIVf_n2uPVtECXuRqTRna/cen_patches_0.25_of.mat?dl=1';
	'cen_patches_0.35_general.mat', 'https://www.dropbox.com/sh/o8g1530jle17spa/AACLJ2qCfrRT0_I-9vYcFeWBa/cen_patches_0.35_general.mat?dl=1';
	'cen_patches_0.35_menpo.mat',   'https://www.dropbox.com/sh/o8g1530jle17spa/AABwj1QgNCun-8Shro506Mu6a/cen_patches_0.35_menpo.mat?dl=1';
	'cen_patches_0.35_of.mat',      'https://www.dropbox.com/sh/o8g1530jle17spa/AADHtF8JImRf6_-wc3i525qca/cen_patches_0.35_of.mat?dl=1';
	'cen_patches_0.50_general.mat', 'https://www.dropbox.com/sh/o8g1530jle17spa/AACx-ZXa_a4pGjfTccTXeZX5a/cen_patches_0.50_general.mat?dl=1';
	'cen_patches_0.50_menpo.mat',   'https://www.dropbox.com/sh/o8g1530jle17spa/AADYfFzbJO6bGMFMoiOUYmepa/cen_patches_0.50_menpo.mat?dl=1';
	'cen_patches_0.50_of.mat',      'https://www.dropbox.com/sh/o8g1530jle17spa/AABBLxrVWKKLpqZU0icA3RvDa/cen_patches_0.50_of.mat?dl=1';
	'cen_patches_1.00_general.mat', 'https://www.dropbox.com/sh/o8g1530jle17spa/AACwz3MBh8UubFod841Afm0_a/cen_patches_1.00_general.mat?dl=1';
	'cen_patches_1.00_menpo.mat',   'https://www.dropbox.com/sh/o8g1530jle17spa/AAD-7AC5jH-8lu0vplqaDKspa/cen_patches_1.00_menpo.mat?dl=1';
	'cen_patches_1.00_of.mat',      'https://www.dropbox.com/sh/o8g1530jle17spa/AAC2z6rAuuYMSnCykVVL1BPja/cen_patches_1.00_of.mat?dl=1';
	};
% OpenFace workaround
openFace.copyfile = {
	'cen_general_mapping.mat', fullfile(libRoot, openFace.dir, 'model_training', 'learn_error_mapping');
	};
% SHINE toolbox
shineTbx.URL = 'http://www.mapageweb.umontreal.ca/gosselif/SHINE/SHINEtoolbox.zip';
shineTbx.zip = 'SHINEtoolbox.zip';
shineTbx.dir = 'SHINEtoolbox';



%%
%  Check MEX setup for C, C++
%
mexCmds = {};
if isempty(mex.getCompilerConfigurations('C'))
	mexCmds = cat(1, mexCmds, 'mex -setup');
end
if isempty(mex.getCompilerConfigurations('C++'))
	mexCmds = cat(1, mexCmds, 'mex -setup C++');
end
if ~isempty(mexCmds)
	msg = sprintf(['Please configure your build environment first. ', ...
		'You can run the following command(s) in the Command Window:\n']);
	for i = 1:length(mexCmds)
		msg = sprintf('%s (%d) %s\n', msg, i, mexCmds{i});
	end
	warning(msg);
	return;
end



%%
%  Prepare library root directory
%
if ~exist(libRoot, 'dir')
	mkdir(libRoot);
end



%%
%  Download and unpack MatConvNet source files
%
if ~exist(fullfile(libRoot, matConvNet.zip), 'file')
	fprintf('downloading MatConvNet...');
	websave(fullfile(libRoot, matConvNet.zip), matConvNet.URL);
	fprintf(' done.\n');
end
if ~exist(fullfile(libRoot, matConvNet.dir), 'dir')
	fprintf('unpacking MatConvNet files...');
	unzip(fullfile(libRoot, matConvNet.zip), libRoot);
	% Quick workaround for MatConvNet 1.0 beta 25
	orgFile = fullfile(libRoot, matConvNet.dir, 'matlab', 'vl_compilenn.org.m');
	newFile = fullfile(libRoot, matConvNet.dir, 'matlab', 'vl_compilenn.m');
	movefile(newFile, orgFile);
	orgScript = fileread(orgFile);
	newScript = strrep(orgScript, 'toolboxdir(''distcomp'')', 'toolboxdir(''parallel'')');
	fid = fopen(newFile, 'w');
	fwrite(fid, newScript);
	fclose(fid);
	clear orgFile newFile orgScript newScript fid;
	fprintf(' done.\n');
end



%%
%  Build MatConvNet MEX files
%
if ~exist(fullfile(libRoot, matConvNet.dir, 'matlab', 'mex'), 'dir')
	fprintf('building MatConvNet MEX files...');
	curDir = cd(fullfile(libRoot, matConvNet.dir));
	addpath('matlab');
	try
		vl_compilenn;
	catch ME
		cd(curDir);
		rethrow(ME);
	end
	cd(curDir);
	fprintf(' done.\n');
end



%%
%  Download and unpack OpenFace files
%
if ~exist(fullfile(libRoot, openFace.zip), 'file')
	fprintf('downloading OpenFace (this may take a while)...');
	websave(fullfile(libRoot, openFace.zip), openFace.URL);
	fprintf(' done.\n');
end
if ~exist(fullfile(libRoot, openFace.dir), 'dir')
	fprintf('unpacking OpenFace files...');
	unzip(fullfile(libRoot, openFace.zip), libRoot);
	% Workaround for OpenFace 2.2.0 matlab_version
	for i = 1:size(openFace.copyfile, 1)
		if ~exist(fullfile(openFace.modelDir, openFace.copyfile{i, 1}), 'file')
			copyfile(fullfile(openFace.copyfile{i, 2}, openFace.copyfile{i, 1}), ...
				fullfile(openFace.modelDir, openFace.copyfile{i, 1}));
		end
	end
	fprintf(' done.\n');
end



%%
%  Download OpenFace model files
%
if ~all(cellfun(@(f) exist(fullfile(openFace.modelDir, f), 'file') > 0, openFace.models(:, 1)))
	fprintf('downloading OpenFace models (this may take a while)');
	for i = 1:size(openFace.models, 1)
		if ~exist(fullfile(openFace.modelDir, openFace.models{i, 1}), 'file')
			websave(fullfile(openFace.modelDir, openFace.models{i, 1}), openFace.models{i, 2});
		end
		fprintf('.');
	end
	fprintf(' done.\n');
end



%%
%  Download and unpack SHINE toolbox
%
if ~exist(fullfile(libRoot, shineTbx.zip), 'file')
	fprintf('downloading SHINE toolbox...');
	websave(fullfile(libRoot, shineTbx.zip), shineTbx.URL);
	fprintf(' done.\n');
end
if ~exist(fullfile(libRoot, shineTbx.dir), 'dir')
	fprintf('unpacking SHINE toolbox...');
	unzip(fullfile(libRoot, shineTbx.zip), libRoot);
	fprintf(' done.\n');
end



%%
%  Wrapping up
%
fprintf('all set, please find the pipeline scripts in the following directories:\n');
fprintf(' (1) pipelines%sKDEF-masked%s\n', filesep, filesep);
fprintf(' (2) pipelines%sCFD-masked%s\n', filesep, filesep);
fprintf(' (3) pipelines%sCFD-cutout%s\n\n', filesep, filesep);
