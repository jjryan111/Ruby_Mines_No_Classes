def make_board(x,y)
  x += 2
  y += 2
  board = Array.new(x) {Array.new(y)}
    (0...x).each do |i|
      (0...y).each do |j|
        if i == 0 || i == (x-1)
          board[i][j] = 10
        elsif j == 0 || j == (y-1)
          board[i][j] = 10
        else
          board[i][j] = 0
        end
      end
    end
    return board
end

def add_bombs(board,bombs)
  while bombs != 0
    a = rand(1...board.length)
    b = rand(1...board[0].length)
    if board[a][b] == 0
      board[a][b] = 100
      bombs -= 1
    end
  end
  return board
end

def add_hints(board, zerolist)
  (1...board.length).each do |i|
    (1...board[0].length).each do |j|
      if board[i][j] == 100
        surrounding_squares(board,i,j,1,10, zerolist)
      end
    end
  end
end

def surrounding_squares(board,x,y,what, threshhold, zerolist)
  (-1..1).each do |i|
    (-1..1).each do |j|
      if board[x+i][y+j] < threshhold
        board[x+i][y+j] += what
        if (x+i).between?(0,board.length-1) && (y+j).between?(0,board[0].length-1)
          zerolist.push(x+i)
          zerolist.push(y+j)
        end
      end
    end
  end
end

def reveal_board (board,zerolist)
  while zerolist.length > 0
    y = zerolist.pop
    x = zerolist.pop
    if board[x][y] == 0
      surrounding_squares(board,x,y,0,11,zerolist)
      board[x][y] += 10
    elsif board[x][y].between?(1,9)
      board[x][y] += 10
    else
    end
  end
  return board
end

def print_board_headers(board)
  (0..board[0].length-3).each do |n|
    print "\t#{(n+65).chr}"
  end
  puts""
  (0..board[0].length).each do |a|
    print "_____"
  end
  print "_\n"
end

def print_game_cell(board, i, j)
  case board[i][j]
    when 10
      print " \t"
    when (11..20)
      print "#{board[i][j] - 10}\t"
    when (21..99)
      print "F\t"
    when 125
      print "F\t"
    else
      print "X\t"
  end
end

def print_solution_cell(board,i, j)
  case board[i][j]
  when 0
    print " \t"
  when (1..9)
    print "#{board[i][j]}\t"
  when 10
    print " \t"
  when (11..19)
    print "#{board[i][j]-10}\t"
  when (20..99)
    print "#{board[i][j]-25}\t"
  else
    print "*\t"
  end
end

def print_board(board,solution)
  print_board_headers(board)
    (1..board.length-2).each do |i|
    print "#{i}|\t"
    (1..board[0].length-2).each do |j|
      case solution
        when 0
          print_game_cell(board,i,j)
        when 1
          print_solution_cell(board,i,j)
        else
          puts "How did we get here?"
        end
    end
    print "\n"
  end
  print "\n"
end

def play_flag(board,x,y,flags_on_bombs)
  zerolist = Array.new
  done = false
  while !done
    print "(P)lay or (F)lag? "
    pf = $stdin.gets.chomp.upcase
    if ["P","F"].include? pf
      done = true
      if pf == "P"
        if board[x][y] > 99
          game_end(board,false)
        else
          zerolist.push(x)
          zerolist.push(y)
          board = reveal_board(board, zerolist)
          print_board(board,0)
        end
      else
        board[x][y] += 25
        if board[x][y] == 125
          flags_on_bombs += 1
        end
        print_board(board,0)
      end
    else
      puts "Please choose p or f."
    end
  end
  return board, flags_on_bombs
end

def play_game(board, bombs)
  flags_on_bombs = 0
  while true
    print "Enter column: "
    column = $stdin.gets.chomp.upcase
    y = column.ord - 64
    print "Enter row: "
    x = $stdin.gets.chomp.to_i
    if x.between?(1,board.length-2) && y.between?(1,board[0].length-2)
      board, flags_on_bombs = play_flag(board,x,y, flags_on_bombs)
      if flags_on_bombs == bombs
        game_end(board,true)
      end
    else
        puts "Invalid input."
    end
  end
end

def game_end(board,wins)
  case wins
  when true
    puts "YOU WIN!!!"
  when false
    puts "BOOM!!"
  else
  end
  print_board(board,1)
  exit(0)
end

def setup_game()
  zerolist = Array.new
  done = false
  while !done
    print "How many rows (Enter 2 to 10)? "
    rows = $stdin.gets.chomp.to_i
    print "How many columns (Enter 2 to 10)? "
    cols = $stdin.gets.chomp.to_i
    if rows.between?(2,10) && cols.between?(2,10)
      print "How many bombs? "
      bombs = $stdin.gets.chomp.to_i
      if bombs > (rows*cols*0.50)
        puts "Too many bombs. That won't be fun."
      else
        done = true
      end
    else
      puts "Invalid input. Try again."
    end
  end
  board = make_board(rows,cols)
  add_bombs(board, bombs)
  add_hints(board, zerolist)
  return board, bombs
end
board, bombs = setup_game()
print_board(board,0)
play_game(board, bombs)
