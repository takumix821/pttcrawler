function list_date = scrap_title(app, url2, pickday,key)
try
    all_day = ceil(datenum(datetime('now'))-datenum(pickday)); % all_day:觀察天數
catch
    all_day = 0;
end
url1 = 'https://www.ptt.cc/bbs/';
url3 = '/index.html';
url = [url1 url2 url3];
opts = weboptions('KeyName','Cookie','KeyValue','over18=1'); % 有的看板會先確認是否成年
if all_day <= 10 * ~isnat(pickday) * ~isempty(key)
    html = string(webread(url,opts));
    % 置底區分隔線"r-list-sep"以下不看
    html = extractBetween(html, '<html>', '<div class="r-list-sep"></div>');
    f = waitbar(0.2,'Please wait...');% 啟動提醒，進度 20%
    
    % 抓出當頁文章的日期list_d
    list_d = extractBetween(html, '<div class="date">', '</div>');
    list_d = flipud(list_d);
    
    list_t = repmat("",length(list_d),1);
    % 抓出當頁文章的標題list_t
    list_t_1 = extractBetween(html, '<div class="title">', '</div>');
    for i = 1:length(list_d)
        try
            list_t(i) = extractBetween(list_t_1(i), '">', '</a>');
        catch
            list_t(i) = "-";
        end
    end
    list_t = flipud(list_t);
    
    % 只保留文章標題有關鍵字(key)的文章的"日期"為一個新的list:list_date_1
    list_date_1 = list_d';
    list_date_1 = list_date_1(contains(list_t,key));
    
    list_date = repelem("",70000);
    % list_date是一個陣列 每次遞迴都會放進文章標題有關鍵字(key)的文章的"日期"
    list_date(1:length(list_date_1)) = list_date_1;
    
    waitbar(0.25,f,'熱門的看板可能會需要一些時間');% 提醒進度 25%
    
    strs = strsplit(list_d(end),'/');
    if month(datetime('now')) < str2double(strs(1))
        list_end = datetime(year(datetime('now'))-1,str2double(strs(1)),str2double(strs(2)));
    else
        list_end = datetime(year(datetime('now')),str2double(strs(1)),str2double(strs(2)));
    end
    
    % 若table的最後一個date >= 起始日
    while list_end >= pickday
        a = extractBetween(html, '<a class="btn wide" href="', '">');
        url = "https://www.ptt.cc" + a(2);
        opts = weboptions('KeyName','Cookie','KeyValue','over18=1'); % 有的看板會先確認是否成年
        html = string(webread(url,opts));
        
        % 抓出當頁文章的日期list_d
        list_d = extractBetween(html, '<div class="date">', '</div>');
        list_d = flipud(list_d);
        
        list_t = repmat("",length(list_d),1);
        % 抓出當頁文章的標題list_t
        list_t_1 = extractBetween(html, '<div class="title">', '</div>');
        for i = 1:length(list_d)
            try
                list_t(i) = extractBetween(list_t_1(i), '">', '</a>');
            catch
                list_t(i) = "-";
            end
        end
        list_t = flipud(list_t);
        
        % 只保留文章標題有關鍵字(key)的文章的"日期"為一個新的list:list_date_1
        list_date_1 = list_d';
        list_date_1 = list_date_1(contains(list_t,key));
        
        plus = length(list_date(list_date ~= "")); % list_date陣列目前的長度
        list_date(1+plus:length(list_date_1)+plus) = list_date_1;
        
        strs = strsplit(list_d(end),'/');
        if month(datetime('now')) < str2double(strs(1))
            list_end = datetime(year(datetime('now'))-1,str2double(strs(1)),str2double(strs(2)));
        else
            list_end = datetime(year(datetime('now')),str2double(strs(1)),str2double(strs(2)));
        end
        
        if (length(list_date_1)+plus)/1000 > 1
            bar = 1;
        else
            bar = 0.75/1000*(length(list_date_1)+plus) + 0.25;
        end
        waitbar(bar,f,'熱門的看板可能會需要一些時間')
    end
    waitbar(1,f,'Finishing');% 最後提醒，進度 100%
    list_date(list_date == "") = [];
    pause(1)
    close(f)
else
    msgbox('請確認是否有輸入關鍵字及日期，並確認是其是否為10天內。')
    list_date = [];
end
end