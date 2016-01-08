function [newData] = changeChanNames(colHdr, data, oldMap, newMap)
    % This function is a standalone function that is used along with
    % getSweepDataFlex.m.  getSweepDataFlex.m also returns a map with
    % channel name keys and double values.  This function allows the user
    % to generate a new dataset with user specified double values for the
    % different channel names.
    %
    % I assume that the data set includes a column for channel names. 
    % (i.e. I assume that 'iCh' or index 4 [at the point of writing this 
    % code] is in 'colsToKeep' [at the point of writing this code] in the 
    % function getSweepDataFlex.m.)
    %
    % colHdr : Headers for the dataset.  Returned from getSweepDataFlex.m
    % data   : Dataset that is returned from getSweepDataFlex.m
    % oldMap : keys must be strings, values must be doubles (generated by
    %          getSweepDataFlex.m, so it should be correct)
    % newMap : keys must be strings, values must be doubles (generated by
    %          user, must make sure that key and value types are correct)
    % oldToNewMap : maps doubles to doubles
    
    chanIdx = find(strcmp(colHdr, 'iCh'));
    % Make sure chanIdx is one number
    assert(size(chanIdx, 1) == 1);
    assert(size(chanIdx, 2) == 1);
    
    % Create a new map that maps from the old values to the new values so
    % that the old values from the data set given in the argument can be
    % replaced by the new values specified by the user
    oldToNewMap = containers.Map('KeyType', 'double', 'ValueType', 'double');
    oldMapKeys = keys(oldMap);
    newMapKeys = keys(newMap);
    
    % This for loop checks to make sure that the new map keys are also in
    % the old map keys (i.e. both dictionaries are mapping from the same
    % channel names)
    listOfMissingChannels = {};
    for i = 1:length(oldMapKeys)
        if isempty(find(strcmp(newMapKeys, oldMapKeys{i}), 1))
            listOfMissingChannels{end+1} = oldMapKeys{i}; %#ok<*AGROW,*NASGU>
        end
    end
    % Throw error message and return if new map is invalid
    if ~isempty(listOfMissingChannels)
        fprintf('Error! Invalid new map for channel names!\n');
        fprintf('Channel name(s): ')
        for i = 1:length(listOfMissingChannels)
            fprintf('%s', listOfMissingChannels{i});
            fprintf(', ');
        end
        fprintf('not in new map!\n');
        fprintf('Returning unmodified data.\n');
        newData = data;
        return
    end
    
    % This for loop create a new dictionary mapping old values (from
    % default map of getSweepDataFlex.m) to new values given by user
    for i = 1:length(oldMapKeys)
        oldVal = oldMap(oldMapKeys{i});
        newVal = newMap(oldMapKeys{i});
        oldToNewMap(oldVal) = newVal;
    end
    
    % Replace old channel values with new values specified by the user in
    % the newMap argument
    newData = data;
    numRows = size(newData, 1);
    for i = 1:numRows
        newData(i,chanIdx) = oldToNewMap(newData(i,chanIdx));
    end
end