# Extend the built-in Enumerable module:
module Enumerable

  # Transform the enumerable into a java HashSet.
  def to_hashset(method = nil, *args)
    return self if self.is_a? java.util.HashSet
    hs = java.util.HashSet.new
    iter = self.each rescue nil
    if not iter and respond_to? :iterator
      iter = self.iterator
    end
    e = iter.next
    if method
      while true
        hs.add e.send(method, *args)
        e = iter.next
      end
    else
      while true
        hs.add e
        e = iter.next
      end
    end
  rescue StopIteration
    return hs
  rescue NativeException => e
    if (e.cause.kind_of?(java.util.NoSuchElementException))
      return hs
    else
      raise
    end
  end

  def to_route(info = nil)
    r = Pacer::Routes::MixedElementsRoute.new(proc { select { |e| e.is_a? Pacer::ElementMixin } })
    r.pipe_class = nil
    r.info = info
    r
  end

  def group_count
    result = Hash.new(0)
    each { |e| result[yield(e)] += 1 }
    result
  end

end
