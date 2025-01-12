require "roda"
require_relative 'templates'
require_relative 'database/database_handle'

def money_format(number)
  return format("%.2f", number)
end

def get_translation(week_day_symbol)
  translation_hash = {
    :sunday => "Domingo",
    :monday => "Segunda-feira",
    :tuesday => "Terça-feira",
    :wednesday => "Quarta-feira",
    :thursday => "Quinta-feira",
    :friday => "Sexta-feira",
    :saturday => "Sábado",
  }

  return translation_hash.fetch(week_day_symbol, '')
end

class Server < Roda

  route do |r|
    @db_handle = DatabaseHandle.new('./db.sqlite3')

    r.root do
      r.redirect "/produtos"
    end

    # /custos
    r.on "custos" do
      r.is do
        costs = @db_handle.get_costs()
        salary_info = @db_handle.get_salary_info()

        context = {
          :costs => costs,
          :salary_info => salary_info
        }

        render_page(Templates.costs, 'Custos', context)
      end

      r.on "adicionar" do
        r.get do
          render_page(Templates.add_cost, 'Adicionar custo')
        end

        r.post do
          data = {
            :name => request.POST['name'],
            :value => request.POST['value'].to_f,
          }

          @db_handle.add_cost(data[:name], data[:value])
          r.redirect '/custos'
        end
      end
    end

    # /jornada
    r.on "jornada" do
      r.on "editar" do
        r.get do
          salary_info = @db_handle.get_salary_info()
          context = {
            :salary => salary_info.salary,
            :days => salary_info.work_week.days,
          }

          render_page(Templates.edit_salary_info, 'Editar jornada de trabalho', context)
        end

        r.post do
          data = {
            :sunday => request.POST['sunday'].to_i,
            :monday => request.POST['monday'].to_i,
            :tuesday => request.POST['tuesday'].to_i,
            :wednesday => request.POST['wednesday'].to_i,
            :thursday => request.POST['thursday'].to_i,
            :friday => request.POST['friday'].to_i,
            :saturday => request.POST['saturday'].to_i,
          }

          @db_handle.update_salary_info(request.POST['salary'].to_f, data)
          r.redirect "/custos"
        end
      end
    end
  end
end

def render_page(template_name, title, context={})
  template_path = File.join('src', 'templates')

  base_template = ERB.new(File.read(File.join(template_path, 'base.erb')))
  filename = if template_name.end_with? '.erb'
             then template_name
             else template_name.concat('.erb') end

  if !context.has_key? :money_format
    context[:money_format] = ->(x) { money_format(x) }
  end

  if !context.has_key? :get_translation
    context[:get_translation] = ->(x) { get_translation(x) }
  end

  template = ERB.new(File.read(File.join(template_path, filename)))

  content = template.result_with_hash(context)
  base_template.result_with_hash({:content => content, :title => "#{title} | Precificador"})
end
