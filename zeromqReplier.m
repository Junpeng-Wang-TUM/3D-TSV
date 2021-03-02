% BSD 2-Clause License
% 
% Copyright (c) 2021, Christoph Neuhauser, Junpeng Wang
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function zeromqReplier
	% Either call the function javaclasspath below, or use:
    % cd(prefdir)
    % edit javaclasspath.txt
    % -> Add a global path to the .jar file.
	addpath('./src'); %% Direct to work path
    javaclasspath('libs/jeromq-0.5.2.jar')
	
    import org.zeromq.SocketType;
    import org.zeromq.ZMQ;
    import org.zeromq.ZContext;
    import java.lang.Thread

    context = ZContext();
    socket = context.createSocket(SocketType.REP);
    socket.bind('tcp://127.0.0.1:17384'); % arbitrary port
    socket.setReceiveTimeOut(1000);

    cleanupObj = onCleanup(@()cleanUpSocket(socket));

    while (~Thread.currentThread().isInterrupted())
        request_string = socket.recvStr(0);
        
        if isempty(request_string)
            continue;
        end
        
        request_string = request_string.toCharArray';

        % native2unicode(..., 'UTF-8') not necessary?
        request = jsondecode(native2unicode(request_string(:)', 'UTF-8'));
        %fprintf('Request string: %s\n', request_string);
        disp(request);

        % ... do something with the received request ...
		%% Hope I understand this function correctly, below you may need to make some adjustment in terms of the 
		%% variable names in case they don't fit.
		%% You can go to check file "RunMission.m" for the data format of these arguments if needed. --- Junpeng
		fileName = request.fileName;
		seedStrategy = request.seedStrategy;
		minimumEpsilon = request.minimumEpsilon;
		numLevels = request.numLevels;
		maxAngleDevi = request.maxAngleDevi;
		snappingOpt = request.snappingOpt;
		minPSLength = request.minPSLength;
		volumeSeedingOpt = request.volumeSeedingOpt;
		traceAlgorithm = request.traceAlgorithm;
		[opt, PSLdatasetFile] = RunMission(fileName, seedStrategy, minimumEpsilon, numLevels, ...
			maxAngleDevi, snappingOpt, minPSLength, volumeSeedingOpt, traceAlgorithm);
		if 0==opt, error('Failed to Generate PSLs!'); end
		
        % Send a reply.
        reply = struct('fileName', PSLdatasetFile);
        reply_string = unicode2native(jsonencode(reply), 'UTF-8');
        %fprintf('Reply string: %s\n', reply_string);
        disp(reply);
        
        socket.send(reply_string, 0);
    end

    function cleanUpSocket(socket)
        socket.close();
    end
end

