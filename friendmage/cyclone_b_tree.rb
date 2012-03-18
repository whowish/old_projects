class Node
  attr_accessor :val,:left, :right
  
  def initialize(val,left,right)
    self.val = val
    self.left = left
    self.right = right
  end
  
  def self.gen_tree(h,v=1)
    
    return nil if h == 0
    n = Node.new(v,gen_tree(h-1,v*2),gen_tree(h-1,v*2+1))
    
    l = nil
    r = nil
    
    l = n.left.val if n.left
    r = n.right.val if n.right

    #puts "#{n.val},#{l},#{r}"
    
    return n
  end
  
  def self.print_node_array(s)
    s.each { |i| print "#{i.val}, " }
    puts
  end
  
end



def peel_left(n,onion_level = 0)
  
  return if n == nil
  
  @onion_left.push([]) while @onion_left.length <= onion_level
  @onion_left[onion_level].push(n.val)
  
  if onion_level == 0
    peel_left(n.left,onion_level)
    peel_left(n.right,onion_level+1)
  else
    peel_left(n.left,onion_level*2)
    peel_left(n.right,onion_level*2+1)
  end
    
end

def peel_right(n,onion_level = 0)
  
  return if n == nil
  
  @onion_right.push([]) while @onion_right.length <= onion_level
  @onion_right[onion_level].push(n.val)
  
  if onion_level == 0
    peel_right(n.left,onion_level+1)
    peel_right(n.right,onion_level)
  else
    peel_right(n.left,onion_level*2+1)
    peel_right(n.right,onion_level*2)
  end
    
end

root = Node.gen_tree(4)

@onion_left = []
@onion_right = []

peel_left(root.left)
peel_right(root.right)

@onion_left.each_index { |i|
  @onion_left[i] = @onion_left[i].reverse if i > 0
  @onion_right[i] = @onion_right[i].reverse
  
  puts "#{@onion_left[i].inspect} ---- #{@onion_right[i].inspect}"
}

@onion_right.reverse!

while @onion_left.length > 0
  
  print "Round: "

  @onion_left.first.each { |i| print "#{i}," }
  @onion_left.shift
  
  
  @onion_left.each_index { |i|
    print "#{@onion_left[i].pop},"
  }
  
  @onion_left = @onion_left.select {|i| i.length > 0}
  
  
  @onion_right.each_index { |i|
    print "#{@onion_right[i].shift},"
  }
  
  @onion_right.last.each { |i| print "#{i}," }
  @onion_right.pop
  
  @onion_right = @onion_right.select {|i| i.length > 0}
  
  puts
end