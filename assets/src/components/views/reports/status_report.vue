<template>
  <div>
    <!-- BEGIN: Subheader -->
    <div class="m-subheader " style="padding: 5px 30px 0 5px;">
        <div class="d-flex align-items-center">
          <div style="z-index: 1000">
          <select  @change="change_date($event)" class="form-control" v-model="key" >
            <option value="1">Today</option>
            <option value="2">Yesterday</option>
            <option value="7">Last 7 Days</option>
            <option value="3">Last 30 Days</option>
          </select>
          </div>
        </div>
    </div>
    <!-- END: Subheader -->
    <div class="m-content">
        <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
            <div class="m-portlet__body" style="padding: 10px">
                <div style="margin: 0 auto; width: 100%" id="visavail_container">
                    <img src="../../../assets/images/loading.gif" id="api-waiting" v-if="show_loading">
                    <p id="draw_report" class="margin-top-5"></p>
                </div>
            </div>
        </div>
    </div>
  </div>
</template>

<script>
import * as d3 from 'd3'
import {visavailChart} from '../../../assets/js/visavail.js'
import '../../../assets/css/visavail.css'
import status_report from './status_report.vue';

export default {
  name: 'status_report',
  data: function(){
    return{
      show_loading: false,
      key: 1
    }
  },
  methods: {
    startReport: function(logs) {
      let draw_report = document.getElementById('draw_report');
      let chart;
      let nvr_logs = logs;
      chart = visavailChart();
      let main_width = document.querySelector("div.m-portlet__body").offsetWidth;
      chart.width(main_width - 150)
      chart.dataHeight = 10
      draw_report.innerHTML = "";
      d3.select(draw_report).datum(logs).call(chart);
    },
    initializeReport: function(days) {
      this.show_loading = true;
      this.$http.get("/update_status_report", {
        params:{
          history_days: days
        }
        }).then(response => {
          this.show_loading = false;
          status_report.methods.startReport(response.body.data)
      });
    },
    change_date: function(event){
      let clickedValues = event.target.value
      this.initializeReport(clickedValues);
    }
  }, // end of methods
   mounted(){
    this.initializeReport(1);
   }
}
</script>

<style lang="scss">
</style>
