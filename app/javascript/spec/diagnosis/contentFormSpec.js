import Vue from 'vue'
import ContentForm from '../../packs/diagnosis/contentForm.vue.erb'

describe('ContentForm', () => {
    it('has a created hook', () => {
        expect(typeof ContentForm.mounted).toBe('function')
    });

    it('sets the correct default data', () => {
        expect(typeof ContentForm.data).toBe('function');

        const defaultData = ContentForm.data();
        expect(defaultData.diagnosis.content).toEqual('');
        expect(defaultData.disabled).toBe(true);
    });

    // it('correctly sets the message when created', () => {
    //     const vm = new Vue(ContentForm).$mount();
    //     expect(vm.message).toBe('bye!');
    // });

// Mount an instance and inspect the render output
//     it('renders the correct message', () => {
//         const Ctor = Vue.extend(MyComponent)
//         const vm = new Ctor().$mount()
//         expect(vm.$el.textContent).toBe('bye!')
//     })
});