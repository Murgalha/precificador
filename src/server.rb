require 'uri'
require 'roda'
require_relative 'templates'
require_relative 'database/database_handle'

def money_format(number)
  return format("%.2f", number)
end

def get_translation(object)
  if object.is_a? WorkDay
    return get_work_day_t object
  elsif object.is_a? MaterialMeasureType
    return get_measure_type_t object
  else
    raise "Invalid type for translation #{object.class}"
  end

  return ''
end

def get_work_day_t(work_day)
  translation_hash = {
    :sunday => "Domingo",
    :monday => "Segunda-feira",
    :tuesday => "Terça-feira",
    :wednesday => "Quarta-feira",
    :thursday => "Quinta-feira",
    :friday => "Sexta-feira",
    :saturday => "Sábado",
  }

  return translation_hash.fetch(work_day.name, '')
end

def get_measure_type_t(measure_type)
  translation_hash = {
    MaterialMeasureType.unit.value => "Unidade",
    MaterialMeasureType.length.value => "Comprimento",
    MaterialMeasureType.area.value => "Área",
    MaterialMeasureType.weight.value => "Peso",
  }

  return translation_hash.fetch(measure_type.value, '')
end

class Server < Roda
  plugin :assets, css: 'styles.css', js: 'utils.js'

  route do |r|
    @db_handle = DatabaseHandle.new('./db.sqlite3')

    r.assets
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

      r.on Integer do |cost_id|
        r.on "editar" do
          r.get do
            cost = @db_handle.get_cost cost_id
            context = { :cost => cost }

            render_page(Templates.edit_cost, "Editar #{cost.name}", context)
          end

          r.post do
            data = {
              :id => cost_id,
              :name => request.POST['name'].strip,
              :value => request.POST['value'].to_f
            }

            @db_handle.update_cost data

            r.redirect "/custos"
          end
        end

        r.on "remover" do
          r.post do
            @db_handle.remove_cost cost_id
            "Custo removido com sucesso"
          end
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

    # /materiais
    r.on "materiais" do
      r.is do
        materials = @db_handle.get_materials

        context = { :materials => materials }

        render_page(Templates.materials, "Materiais", context)
      end

      r.on "adicionar" do
        r.get do
          measure_types = [
            MaterialMeasureType.unit,
            MaterialMeasureType.length,
            MaterialMeasureType.area,
            MaterialMeasureType.weight,
          ]

          context = { :measure_types => measure_types }

          render_page(Templates.add_material, "Adicionar material", context)
        end

        r.post do
          name = request.POST['name'].strip
          note = request.POST['note'].strip
          type = request.POST['type'].to_i
          price = request.POST['price'].to_f
          bw = request.POST['base-width'].to_i
          bl = request.POST['base-length'].to_i

          @db_handle.add_material(name, note, type, price, bw, bl)

          r.redirect "/materiais"
        end
      end
    end

    # /produtos
    r.on "produtos" do
      r.is do
        products = @db_handle.get_products_summary
        context = { :products => products }

        render_page(Templates.products, 'Produtos', context)
      end

      r.is Integer do |product_id|
        product = @db_handle.get_product(product_id)
        salary_info = @db_handle.get_salary_info
        costs = @db_handle.get_costs

        context = {:product => product, :salary_info => salary_info, :monthly_costs => costs}
        render_page(Templates.product_details, product.name, context)
      end

      r.on "adicionar" do
        r.get do
          materials = @db_handle.get_materials
          context = { :materials => materials }

          render_page(Templates.add_product, 'Adicionar produto', context)
        end

        r.post do
          params = parse_body_with_list_param(request.body)

          data = {
            :name => params['name'].first.strip,
            :description => params['description'].first.strip,
            :work_time => params['work-time'].first.to_i,
            :profit => params['profit'].first.to_i,
            :materials => params['material-name'].zip(params['material-quantity']),
          }

          @db_handle.add_product(data)
          r.redirect "/produtos"
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

def parse_body_with_list_param(body)
  body_str = URI.decode_www_form_component(body.read)
  params = {}

  body_str.split('&').each do |param|
    split = param.split('=')
    name = split[0]
    value = if split[1] != nil then split[1] else '' end

    if !params.has_key? name
      params[name] = []
    end

    params[name].append(value)
  end

  return params
end
