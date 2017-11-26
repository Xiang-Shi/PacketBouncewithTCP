function readThreeFilesAndSave(Threshold,A,finalfile,num)

filename1 = '1_outsplit.csv';

queueCapacity = 100;

data_1 = csvread(filename1,1,1);
RD_1 = tabulate(data_1(:));
RD_1(:,3) = RD_1(:,3)/100; 
mean1 = mean(data_1(:));

%reorder entropy
ER_1 = -1*sum(RD_1(:,3).*log(RD_1(:,3)));
%===============================================
filename2 = '2_outsplit.csv';
data_2 = csvread(filename2,1,1);
RD_2 = tabulate(data_2(:));
RD_2(:,3) = RD_2(:,3)/100; 
mean2 = mean(data_2(:));

ER_2 = -1*sum(RD_2(:,3).*log(RD_2(:,3)));
%===============================================
filename3 = '3_outsplit.csv';
data_3 = csvread(filename3,1,1);
RD_3 = tabulate(data_3(:));
RD_3(:,3) = RD_3(:,3)/100; 
mean3 = mean(data_3(:));

ER_3 = -1*sum(RD_3(:,3).*log(RD_3(:,3)));
%===============================================
filename4 = 'reversePassback1.csv';
filename5 = 'reversePassback2.csv';
filename6 = 'reversePassback3.csv';

data_4 = csvread(filename4,1,4);
data_5 = csvread(filename5,1,4);
data_6 = csvread(filename6,1,4);

total = data_4 + data_5 + data_6;

%===============================================
filename7 = 'queue/dataQueueLen_max.csv';
filename8 = 'queue/passBackQueueLen_max.csv';
data_7 = csvread(filename7,1,4);
data_8 = csvread(filename8,1,4);
data_7 = data_7/queueCapacity;
data_8 = data_8/queueCapacity;

%max queue utilization of every eth port
data_max_avg = (data_7 + data_8)/2;

%max queue utilization of every switch
j = 1;
for i = 1:2:size(data_max_avg,1)
    temp(j,:) = (data_max_avg(i,:) + data_max_avg(i+1,:))/2;
    j = j+1;
end

j = 1;
for i = 1:size(temp,1)-1
    util_max_switch(j,:) = temp(i,:);
    if(j == 7)
      util_max_switch(j,:) = (temp(i,:) + temp(i+1,:))/2;
    end
    j = j+1;

end
% variance of max queue utilization of every switch
dataLen_max_variance = var(util_max_switch,1);

%===============================================
filename9 = 'queue/dataQueueLen_timeavg.csv';
filename10 = 'queue/passBackQueueLen_timeavg.csv';
data_9 = csvread(filename9,1,4);
data_10 = csvread(filename10,1,4);

data_timeavg_avg = (data_9 + data_10)/2;

%timeavg queue utilization of every switch
j = 1;
for i = 1:2:size(data_timeavg_avg,1)
    temp(j,:) = (data_timeavg_avg(i,:) + data_timeavg_avg(i+1,:))/2;
    j = j+1;
end

j = 1;
for i = 1:size(temp,1)-1
    util_timeavg_switch(j,:) = temp(i,:);
    if(j == 7)
      util_timeavg_switch(j,:) = (temp(i,:) + temp(i+1,:))/2;
    end
    j = j+1;

end

dataLen_timeavg_variance = var(util_timeavg_switch,1);



if((mean1 || mean2 || mean3)~=0)  %reordering density error
    ER_avg = -1;
elseif(total ~= 0)   %bidirectional pass back error
    ER_avg = -2;
elseif((mean1 && mean2 && mean3 && total) == 0)
    ER_avg = (ER_1+ER_2+ER_3)/3;
end

 
f = fopen('finalRecord.txt','a+');
fprintf(f,'%f %d %f %f %f\n',Threshold,A,ER_avg,dataLen_max_variance,dataLen_timeavg_variance);
fclose(f);
%xlswrite(finalfile,[Threshold,A,ER_avg],1,sprintf('A%d',num));
end