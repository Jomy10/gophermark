#!/usr/bin/env ruby

# Convert txt files to xls

require "spreadsheet"

extensionReg = /.*?\.txt/

# New spreadsheet
book = Spreadsheet::Workbook.new

# TODO: sort files by number
Dir.each_child('.') do |file|
    if extensionReg.match file
        sheetName = ""
        if /(?<name>.*?)\.txt/ =~ file 
            sheetName = name
        end
        sheet = book.create_worksheet :name => sheetName

        contents = File.read file
        split = contents.split "\n"

        sheet[0,0] = "date"
        sheet[0,1] = "ms"

        row = 1
        for rowS in split
            if /(?<date>\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}) (?<ms>\d+.\d*)/ =~ rowS
                sheet[row, 0] = date
                sheet[row, 1] = ms.to_f
                row += 1
            end
        end
    end
end

book.write 'data.xls'
