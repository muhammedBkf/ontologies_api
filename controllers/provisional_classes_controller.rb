class ProvisionalClassesController < ApplicationController
  ##
  # Ontology provisional classes
  get "/ontologies/:ontology/provisional_classes" do
    check_last_modified_collection(LinkedData::Models::ProvisonalClass)
    ont = Ontology.find(params["ontology"]).include(provisionalClasses: LinkedData::Models::ProvisonalClass.goo_attrs_to_load(includes_param)).first
    error 404, "You must provide a valid id to retrieve provisional classes for an ontology" if ont.nil?
    reply ont.provisionalClasses
  end

  namespace "/provisional_classes" do
    # Display all provisional_classes
    get do
      check_last_modified_collection(LinkedData::Models::ProvisonalClass)
      prov_class = ProvisionalClass.where.include(ProvisionalClass.goo_attrs_to_load(includes_param)).to_a
      reply prov_class
    end

    # Display a single provisional_class
    get '/:provisional_class_id' do
      check_last_modified_collection(LinkedData::Models::ProvisonalClass)
      id = params["provisional_class_id"]
      pc = ProvisionalClass.find(id).include(ProvisionalClass.goo_attrs_to_load(includes_param)).first
      error 404, "Provisional class #{id} not found" if pc.nil?
      reply 200, pc
    end

    # Create a new provisional_class
    post do
      pc = instance_from_params(ProvisionalClass, params)

      if pc.valid?
        pc.save
      else
        error 400, pc.errors
      end
      reply 201, pc
    end

    # Update an existing submission of an provisional_class
    patch '/:provisional_class_id' do
      id = params["provisional_class_id"]
      pc = ProvisionalClass.find(id).include(ProvisionalClass.attributes).first

      if pc.nil?
        error 400, "Provisional class does not exist, please create using HTTP POST before modifying"
      else
        populate_from_params(pc, params)

        if pc.valid?
          pc.save
        else
          error 400, pc.errors
        end
      end
      halt 204
    end

    # Delete a provisional_class
    delete '/:provisional_class_id' do
      pc = ProvisionalClass.find(params["provisional_class_id"]).first
      pc.delete
      halt 204
    end
  end
end
