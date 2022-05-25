#!/usr/bin/env ruby

# Convert txt files to xls

require "spreadsheet"

extensionReg = /.*?\.txt/

# New spreadsheet
book = Spreadsheet::Workbook.new

# Collect all files
files = []
Dir.each_child('.') do |file|
    if extensionReg.match file
        files.push file
    end
end

# Sort all files (less gophers to more gophers)
files.sort! { |f1, f2| 
    f1N = 0
    f2N = 0
    if /(?<name>.*?)\.txt/ =~ f1 
        f1N = name.to_i
    end
    if /(?<name>.*?)\.txt/ =~ f2
        f2N = name.to_i
    end


    f1N <=> f2N
}

# Add data to spreadsheets
files.each do |file|
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

# Write file
book.write 'data.xls'
