module Compare
  extend ActiveSupport::Concern

  def diff
    return [] if user_params[:old].nil? || user_params[:new].nil?

    build_diff(user_params[:old].to_hash, user_params[:new].to_hash)
  end

  private

  def build_diff(old, new, diff = [], parent = nil)
    (old.keys | new.keys).each_with_object({}) do |k, o|
      if old[k].is_a?(Hash) && new[k].is_a?(Hash)
        build_diff(old[k], new[k], diff, k)
        next
      elsif old[k] != new[k]
        o['field'] = [parent, k].compact.join('.')
        o['old'] = old[k]
        o['new'] = new[k]
      end
      diff << o unless diff.include? o
    end
    diff
  end
end
