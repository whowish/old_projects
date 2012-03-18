class Node
  attr_accessor :left, :right, :i

  def initialize(i)
    @i = i
  end


end

a = [1,2,3,4,5,6,7,8,9,10]

height = 1
number = a.length

while number <= 1
  height = height + 1
  number = (number / 2).to_i
end

root = nil

current_height = 1

a.each { |i|

  n = Node.new(i)

  if root == nil
    root = n
  elsif current_height == 1
    n.left = root
    root = n
    current_height = current_height + 1
  elsif root.right == nil
    root.right = n
  elsif (n-i) < (i/2)
    t = root.right
    root.right = n
    n.left = t
  elsif (n-i) < i
  end
}

