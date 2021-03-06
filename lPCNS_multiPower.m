function [lickPercent] = lPCNS_multiPower(dataInput, stimDirname, bins)

stimInfo = pulseJackerPosition1020(stimDirname); %Calls pulseJackerPosition function to obtain info about which trials we stimulated on
%stimInfo = noPulsePosition(dataInput);
stimIndex = find(~stimInfo(:,3)); %Indices of trials with a stimulation
sizeStimInfo = numel(stimIndex); 
        
        motorPositionDat = cell2mat(dataInput.MotorsSection_motor_position);
        if numel(motorPositionDat) ~= length(stimInfo(:,3)) %Throw out an error if the trial numbers don't match due to possibility of all trials being off 
            error('number of trials must be the same for motor position and pulse jacker data') 
        end 
        motorPositionDat = motorPositionDat(stimIndex); %Takes only the motor positions of the trials with a stimulation
        
        totalTrials = sizeStimInfo;
        
        lickingArray = lickArrayMaker(dataInput); %Uses lickArrayMaker code I wrote to make a matrix of whether a lick occurs
        lickingArray= lickingArray(stimIndex); % Same as above
        
        motorPosBins = (180000/bins):(180000/bins):180000; %Makes bins
        
        lickProb = zeros(1,bins);
        for motorPosIndex = 1:bins; %Loop command for each bin
            motorRangeStart = motorPosIndex*(180000/bins)-(180000/bins); % Subtract 10,000 so as to start at 0 and go by increments of 10,000
            motorRangeEnd = motorPosIndex*(180000/bins);
            trialsInRangeArray = (motorPositionDat >= motorRangeStart & motorPositionDat < motorRangeEnd);
            trialsInRange = sum(trialsInRangeArray);
            
            
            licksInRangeArray = zeros(1,totalTrials);
            for lickIndex = 1:totalTrials; %Loop command for all trials, forms array with all licks that occur within specified range
                if (lickingArray(lickIndex) == 1) && (motorPositionDat(lickIndex) >= motorRangeStart) && (motorPositionDat(lickIndex) < motorRangeEnd)
                    licksInRangeArray(lickIndex) = 1;
                else licksInRangeArray(lickIndex) = 0;
                end
            end
            licksInRange = sum(licksInRangeArray);
            
            lickProb(motorPosIndex) = licksInRange/trialsInRange;
        end
        
        lickPercent = 100*lickProb;
        
        %scatter(motorPosBins,lickPercent) % Crude scatterplot, note that axes will not quite be accurate, since they'll be listed by the last value in the range, not the range itself)
end