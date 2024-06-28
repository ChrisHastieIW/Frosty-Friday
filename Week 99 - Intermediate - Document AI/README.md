
# Frosty Friday Week 99 - Intermediate - Document AI

The original challenge can be found [here](https://frostyfriday.org/blog/2024/06/28/week-99-intermediate/).

## Document AI

The main code for this challenge sits inside the SQL script, however a large portion of the challenge required navigating the relevant pages in the Snowsight UI. These steps are as follows:

1. Create a new build within the Document AI area

    ![Create build](images/01__create_build.png)

    After creating the build, the following landing area is shown

    ![Draft build](images/02__draft_build.png)

2. Select the "Upload documents" button to upload the documents that underpin the model

    ![Upload documents 1](images/03__upload_documents_1.png)
    ![Upload documents 2](images/04__upload_documents_2.png)

3. Once uploaded, the number of documents will be reflected in the documents area of the landing page.

    ![alt text](images/05__documents_uploaded.png)

    The documents will automatically be processed by the default model

    ![alt text](images/06__documents_processing.png)

4. Select "Define values" to begin defining the data to be retrieved from the files

    ![alt text](images/07__define_values.png)

    This will show an area where you can enter questions using natural language to retrieve data from the file

    ![alt text](images/08__populate_values.png)

    When you are happy with your questions, flick through other documents to evaluate the answers and modify your questions

    ![alt text](images/09__confirm_values.png)

5. After defining your values, view them on the "Values" tab. This includes the model's approximation as to its accuracy

    ![alt text](images/10__review_values.png)

6. At any point, you can navigate to the "Documents" tab to see the documents and modify any reviewed values

    ![alt text](images/11__review_documents.png)

7. To improve the accuracy of the model using your reviewed values, train it by selecting "Train model" on the landing page

    ![alt text](images/12__train_model.png)

    This will trigger the training of the model. Be warned, this can take a while!

    ![alt text](images/13__train_in_progress.png)

    Afterwards, the model will be trained and you should see an improvement in the accuracy.

    ![alt text](images/14__model_trained.png)

8. If you prefer to publish directly without training, you can also publish directly with "Publish version"

    ![alt text](images/15__publish_version.png)

9. Once a model is published, some sample queries will be made available for leveraging the model. A version of these queries is used in the SQL script for this challenge.

    ![alt text](images/16__extracting_query.png)

## Final Output

Here is a screenshot of the final output from the SQL script:

![Final Output](images/00__final_output.png)
