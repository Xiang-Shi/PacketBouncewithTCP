function readThreeFilesAndSave(Threshold,A,finalfile,num)



filename1 = '1_outsplit.csv';

queueCapacity = 100;

data_1 = csvread(filename1,1,1);
RD_1 = tabulate(data_1(:));
RD_1(:,3) = RD_1(:,3)/100; 
mean1 = mean(data_1(:));
%======================= reorder entropy ========================

ER_1 = -1*sum(RD_1(:,3).*log(RD_1(:,3)));
%----------------------------------------------------------------
filename2 = '2_outsplit.csv';
data_2 = csvread(filename2,1,1);
RD_2 = tabulate(data_2(:));
RD_2(:,3) = RD_2(:,3)/100; 
mean2 = mean(data_2(:));

ER_2 = -1*sum(RD_2(:,3).*log(RD_2(:,3)));
%----------------------------------------------------------------
filename3 = '3_outsplit.csv';
data_3 = csvread(filename3,1,1);
RD_3 = tabulate(data_3(:));
RD_3(:,3) = RD_3(:,3)/100; 
mean3 = mean(data_3(:));

ER_3 = -1*sum(RD_3(:,3).*log(RD_3(:,3)));
%----------------------------------------------------------------
filename4 = 'reversePassback1.csv';
filename5 = 'reversePassback2.csv';
filename6 = 'reversePassback3.csv';

data_4 = csvread(filename4,1,4);
data_5 = csvread(filename5,1,4);
data_6 = csvread(filename6,1,4);

total = data_4 + data_5 + data_6;

ER_avg = 0;
variance_avg = 0;
timeRatio_avg_all = 0; %time ratio of all switch 1-7 when utilization is above threshold
timeRatio_avg_1 = 0; %time ratio of switch1,2,3 when utilization is above threshold
timeRatio_avg_2 = 0; %time ratio of switch4,5,6 when utilization is above threshold
timeRatio_avg_3 = 0; %time ratio of switch7 when utilization is above threshold

if((mean1 || mean2 || mean3)~=0)  %reordering density error
    ER_avg = -1;
    variance_avg = -1;
    timeRatio_avg_all = -1;
    timeRatio_avg_1 = -1;
    timeRatio_avg_2 = -1;
    timeRatio_avg_3 = -1;

elseif(total ~= 0)   %bidirectional pass back error
    ER_avg = -2;
    variance_avg = -2;
    timeRatio_avg_all = -2;
    timeRatio_avg_1 = -2;
    timeRatio_avg_2 = -2;
    timeRatio_avg_3 = -2;
elseif((mean1 && mean2 && mean3 && total) == 0)
    ER_avg = (ER_1+ER_2+ER_3)/3;
    

    %======================= queue utilization variance ========================
    filename7 = 'queue/allSwitchQueueLen_vector.csv';
    redun_table = readtable(filename7);
    redun_double = table2array(redun_table);

    % remove columns of pause queue data (2,5,8...47)
    j = 1;
    for i = 1:size(redun_double,2)
        if( mod(i-2,3) ~= 0)
            temp_1(:,j) = redun_double(:,i);  
            j = j+1;
        end
    end
    
    %fill blank
    for j = 2:size(temp_1,2)
        for i = 2:size(temp_1,1)
            if( isnan(temp_1(i,j)) )
                temp_1(i,j) = temp_1(i-1,j);
            end
        end
    end
    
    % calculate the avg time ratio when util is over the threshold
    % s1.eth[1].passbackQueue,  s1.eth[1].dataQueue
    % s2.eth[1].passbackQueue,  s2.eth[1].dataQueue
    % ....
    % s6.eth[1].passbackQueue,  s6.eth[1].dataQueue
    % s7.eth[3].passbackQueue,  s7.eth[3].dataQueue
    timeRatio = zeros(1,14);
    row_id = [4,5,8,9,12,13,16,17,20,21,24,25,32,33];

    for j = 1:size(row_id,2)
        timeLen = 0;
        start = 0;
        for i = 1:size(temp_1,1)
            if( temp_1(i,row_id(j)) > (queueCapacity * Threshold))
            %find one over threshold
                if (start == 0)
                % start == 0, 
                % set start
                    start = temp_1(i,1);
                end
            else
            %find one not over threshold
                if (start ~= 0)
                    timeLen = timeLen + temp_1(i,1) - start;
                    start = 0;
                end
            end
        end
        timeRatio(1,j) = timeLen/temp_1(size(temp_1,1),1);
    end
    timeRatio_avg_all = mean(timeRatio);
    timeRatio_avg_1 = mean(timeRatio(1:6));
    timeRatio_avg_2 = mean(timeRatio(7:12));
    timeRatio_avg_3 = mean(timeRatio(13:14));

    % merge row with the same time by averaging 
    temp1_size1 = size(temp_1,1);
    temp1_size2 = size(temp_1,2);

    temp_2 = zeros(size(temp_1)); % malloc memory first
    i = 2;
    k = 1;
    temp_2(k,:) = temp_1(i-1,:);
    k = 2;
    sameNum = 1;
    while( i <= temp1_size1)
        % check if temp_1(i,1) exists in temp_2, temp_2(k-1,1) == temp_1(i,1)

        if (temp_2(k-1,1) == temp_1(i,1))
            % temp_1(i,1) exists in temp_2 
            % add temp_1(i,2...) to temp_2(k-1,2...)
            temp_2(k-1,2:temp1_size2) = temp_2(k-1,2:temp1_size2) + temp_1(i,2:temp1_size2);
            sameNum = sameNum + 1;
            i = i + 1;
        else 
            % temp_1(i,1) does not exists in temp_2, 
            % divide temp_2(k-1,2...) with sameNum and put temp_1(i,1) into temp_2
            if (sameNum ~= 1)
                temp_2(k-1,2:temp1_size2) = temp_2(k-1,2:temp1_size2)/sameNum;
                sameNum = 1;
            end

            temp_2(k,:) = temp_1(i,:);
            k = k+1;
            i = i+1;
        end
    end
    % deal with the final one
    temp_2(k-1,2:size(temp_1,2)) = temp_2(k-1,2:size(temp_1,2))/sameNum;

    temp_2_size1 = k-1;

    % merge column within the same switch 
    temp_3 = zeros(temp_2_size1,8); % malloc memory first
    temp_3(:,1) = temp_2(1:temp_2_size1,1);
    j = 2;
    for i = 2:4:26
        if( i == 26)
             temp_3(:,j) = temp_2(1:temp_2_size1,i) + temp_2(1:temp_2_size1,i+1) + temp_2(1:temp_2_size1,i+2) + temp_2(1:temp_2_size1,i+3)+temp_2(1:temp_2_size1,i+4) + temp_2(1:temp_2_size1,i+5) + temp_2(1:temp_2_size1,i+6) + temp_2(1:temp_2_size1,i+7);
             temp_3(:,j) = temp_3(:,j) / (8*queueCapacity);
        else
             temp_3(:,j) = temp_2(1:temp_2_size1,i) + temp_2(1:temp_2_size1,i+1) + temp_2(1:temp_2_size1,i+2) + temp_2(1:temp_2_size1,i+3);
             temp_3(:,j) = temp_3(:,j) / (4*queueCapacity);
        end
        j = j+1;

    end

    % caculate the variance of each row 
    variance = zeros(size(temp_3,1),1); % malloc memory first

    for i = 1:size(temp_3,1)
        variance(i) = var(temp_3(i,2:size(temp_3,2)),1);
    end

    variance_avg = mean(variance(:));

end



f = fopen('finalRecord.txt','a+');
fprintf(f,'%f %d %f %f %f %f %f %f\n',Threshold,A,ER_avg,variance_avg,timeRatio_avg_all,timeRatio_avg_1,timeRatio_avg_2, timeRatio_avg_3);
fclose(f);
end